module Hem

  class << self
    attr_accessor :cli
  end

  # Utility error to shortcut exit routine within actions
  class Halt < Error
  end

  # Main application class
  class Cli
    include Hem::Logging

    attr_accessor :slop, :help_formatter

    # @param [Hash] Initialization accepts several options in a hash:
    #     - :slop - Slop instance
    #     - :help - Help formatter instance
    #     - :host_check - Host check invocation class
    #
    # :help and :host_check are only used by tests.
    # :slop is used to ensure low-level args parsed in bin/hem are propagated to the application
    def initialize opts = {}
      @opts = opts
      @slop = opts[:slop] || Slop.new
      @help_formatter = opts[:help] || Hem::HelpFormatter.new(@slop)
      @help_opts = {}
      @host_check = opts[:host_check] || Hem::Lib::HostCheck
    end

    # entry point for application
    # @param [Array] Arguments from ARGV. Defaults to ARGV
    def start args = ARGV
      load_user_config
      load_builtin_tasks
      load_hemfiles
      load_project_config
      load_plugins
      Hem.chefdk_compat

      tasks = structure_tasks Hem::Metadata.metadata.keys
      define_global_opts @slop

      begin
        # Parse out global args first
        @slop.parse! args
        opts = @slop.to_hash

        perform_host_checks unless opts[:'skip-host-checks']

        @help_opts[:all] = opts[:all]

        @slop.add_callback :empty do
          show_help
        end

        # Necessary to make command level help work
        args.push "--help" if @slop.help?

        @help_formatter.command_map = define_tasks(tasks, @slop)
        remaining = @slop.parse! args

        raise Hem::InvalidCommandOrOpt.new remaining.join(" ") if remaining.size > 0

        show_help if @slop.help?
      rescue Halt
        # NOP
      end

      return 0
    end

    # Display help and exit
    # @param [Hash] Options to apss to help formatter.
    # Options are mostly used for filtering
    def show_help(opts = {})
      Hem.ui.info @help_formatter.help(@help_opts.merge(opts))
      halt
    end

    private

    def load_builtin_tasks
      require_relative 'tasks'
    end

    def load_user_config
      Hem.user_config = Hem::Config::File.load Hem.user_config_file
    end

    def load_project_config
      if Hem.in_project?
        Hem.project_config = Hem::Config::File.load Hem.project_config_file
      else
        Hem.project_config = DeepStruct.wrap({})
      end
    end

    def load_hemfiles
      if Hem.in_project? && File.exists?(Hem.hemfile_path)
        logger.debug("cli: Loading hemfile @ #{Hem.hemfile_path}")
        eval(File.read(Hem.hemfile_path), TOPLEVEL_BINDING, Hem.hemfile_path)
      end

      if File.exists?(Hem.user_hemfile_path)
        logger.debug("cli: Loading hemfile @ #{Hem.user_hemfile_path}")
        eval(File.read(Hem.user_hemfile_path), TOPLEVEL_BINDING, Hem.user_hemfile_path)
      end
    end

    def load_plugins
      Hem.plugins.install unless Hem.plugins.check
      Hem.plugins.require
    end

    def perform_host_checks
      checks = [
        'vagrant.*',
        'ssh_present',
        'git_present'
      ]

      @host_check.check(
        :filter => /#{checks.join('|')}/,
        :raise => true
      )
    end

    def define_global_opts slop
      slop.on '-a', '--all', 'Show hidden commands'
      slop.on '-h', '--help', 'Display help'

      slop.on '-v', '--version', 'Print version information' do
        Hem.ui.info "Hem version #{Hem::VERSION}"
        halt
      end
    end

    def halt
      raise Halt.new
    end

    # Takes a nested hash of commands and creates nested Slop instances populated with metadata.
    #
    # @param [Hash] A nested hash of namespaces & commands.
    # @param [Slop] A slop instance on which to define tasks.
    # @param [Array] Stack of string names of parental namespaces.
    # @param [Hash] Hash of "namespace:command" => Slop instances.
    # @return [Hash] Hash of "namespace:command" => Slop instances.
    def define_tasks structured_list, scope, stack = [], map = {}
      structured_list.each do |k, v|
        name = (stack + [k]).join(':')
        new_stack = stack + [k]
        logger.debug("cli: Defined #{name}")
        map[name] = if v.size == 0
          define_command(name, scope, new_stack)
        else
          define_namespace(name, scope, new_stack, v, map)
        end
      end
      return map
    end

    # Map rake namespace to a Slop command
    def define_namespace name, scope, stack, subtasks, map
      metadata = Hem::Metadata.metadata[name]
      hem = self
      new_scope = nil

      scope.instance_eval do
        new_scope = command stack.last do

          description metadata[:desc]
          long_description metadata[:long_desc]
          hidden metadata[:hidden]
          project_only metadata[:project_only]

          # NOP; run runs help anyway
          on '-h', '--help', 'Display help' do end

          run do |opts, args|
            hem.show_help(target: name)
          end
        end
      end

      define_tasks subtasks, new_scope, stack, map
      return new_scope
    end

    # Map rake task to a Slop command
    def define_command name, scope, stack
      metadata = Hem::Metadata.metadata[name]
      hem = self
      new_scope = nil

      scope.instance_eval do
        new_scope = command stack.last do
          task = Rake::Task[name]

          description metadata[:desc]
          long_description metadata[:long_desc]
          arg_list metadata[:arg_list]
          hidden metadata[:hidden]
          project_only metadata[:project_only]

          metadata[:opts].each do |opt|
            on *opt
          end if metadata[:opts]

          on '-h', '--help', 'Display help' do
            hem.show_help(target: name)
          end

          run do |opts, args|
            Dir.chdir Hem.project_path if Hem.in_project?
            raise ::Hem::ProjectOnlyError.new if opts.project_only && !Hem.in_project?
            task.opts = opts.to_hash.merge({:_unparsed => hem.slop.unparsed})

            task.invoke *Helper::convert_args(name, args, metadata[:arg_list])
            task.opts = nil
          end
        end
      end

      return new_scope
    end

    # Expand flat task list in to hierarchy (non-recursive)
    # @param [Array] List of strings with entries of the form "namespace1:namespace2:task"
    def structure_tasks list
      out = {}
      list.each do |name|
        ref = out
        name = name.split(":")
        name.each do |n|
          ref[n] ||= {}
          ref = ref[n]
        end
      end
      out
    end
  end
end
