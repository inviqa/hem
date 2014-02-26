require 'slop'
require 'deepstruct'

module Hobo

  class << self
    attr_accessor :cli
  end

  class Halt < Error
  end

  class Cli
    include Hobo::Logging

    attr_accessor :slop, :help_formatter

    def initialize opts = {}
      @opts = opts
      @slop = opts[:slop] || Slop.new
      @help_formatter = opts[:help] || Hobo::HelpFormatter.new(@slop)
      @help_opts = {}
    end

    def start args = ARGV

      load_user_config
      load_builtin_tasks
      load_hobofiles
      load_project_config

      tasks = structure_tasks Hobo::Metadata.metadata.keys
      define_global_opts @slop

      begin
        # Parse out global args first
        @slop.parse! args
        opts = @slop.to_hash

        Hobo::Lib::HostCheck.check(:filter => /vagrant.*|.*present/, :raise => true) unless opts[:'skip-host-checks']

        @help_opts[:all] = opts[:all]
        Hobo.ui.interactive = !(opts[:'non-interactive'] == true)

        @slop.add_callback :empty do
          show_help
        end

        # Necessary to make command level help work
        args.push "--help" if @slop.help?

        @help_formatter.command_map = define_tasks(tasks, @slop)

        remaining = @slop.parse! args
        raise Hobo::InvalidCommandOrOpt.new remaining.join(" "), self if remaining.size > 0

        show_help if @slop.help?
      rescue Halt
        # NOP
      end

      return 0
    end

    def show_help(opts = {})
      Hobo.ui.info @help_formatter.help(@help_opts.merge(opts))
      halt
    end

    private

    def load_builtin_tasks
      require 'hobo/tasks/assets'
      require 'hobo/tasks/config'
      require 'hobo/tasks/debug'
      require 'hobo/tasks/deps'
      require 'hobo/tasks/system'
      require 'hobo/tasks/system/completions'
      require 'hobo/tasks/seed'
      require 'hobo/tasks/vm'
      require 'hobo/tasks/tools'
    end

    def load_user_config
      Hobo.user_config = Hobo::Config::File.load Hobo.user_config_file
    end

    def load_project_config
      if Hobo.in_project?
        Hobo.project_config = Hobo::Config::File.load Hobo.project_config_file
      else
        Hobo.project_config = DeepStruct.wrap({})
      end
    end

    def load_hobofiles
      if Hobo.in_project? && File.exists?(Hobo.hobofile_path)
        logger.debug("cli: Loading hobofile @ #{Hobo.hobofile_path}")
        TOPLEVEL_BINDING.eval File.read(Hobo.hobofile_path)
      end

      if File.exists?(Hobo.user_hobofile_path)
        logger.debug("cli: Loading hobofile @ #{Hobo.user_hobofile_path}")
        TOPLEVEL_BINDING.eval File.read(Hobo.user_hobofile_path)
      end
    end

    def define_global_opts slop
      slop.on '-a', '--all', 'Show hidden commands'
      slop.on '-h', '--help', 'Display help'
      slop.on '--non-interactive', 'Run non-interactively. Defaults will be automatically used where possible.'
      slop.on '--skip-host-checks', 'Skip host checks'

      slop.on '-v', '--version', 'Print version information' do
        Hobo.ui.info "Hobo version #{Hobo::VERSION}"
        halt
      end
    end

    def halt
      raise Halt.new
    end

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
      metadata = Hobo::Metadata.metadata[name]
      hobo = self
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
            hobo.show_help(target: name)
          end
        end
      end

      define_tasks subtasks, new_scope, stack, map
      return new_scope
    end

    # Map rake task to a Slop command
    def define_command name, scope, stack
      metadata = Hobo::Metadata.metadata[name]
      hobo = self
      new_scope = nil

      scope.instance_eval do
        new_scope = command stack.last do
          task = Rake::Task[name]

          description metadata[:desc]
          long_description metadata[:long_desc]
          arg_list task.arg_names
          hidden metadata[:hidden]
          project_only metadata[:project_only]

          metadata[:opts].each do |opt|
            on *opt
          end if metadata[:opts]

          on '-h', '--help', 'Display help' do
            hobo.show_help(target: name)
          end

          run do |opts, args|
            Dir.chdir Hobo.project_path if Hobo.in_project?
            raise ::Hobo::ProjectOnlyError.new if opts.project_only && !Hobo.in_project?
            task.opts = opts.to_hash.merge({:_unparsed => hobo.slop.unparsed})
            raise ::Hobo::MissingArgumentsError.new(name, args, hobo) if args && task.arg_names.length > args.length
            task.invoke *args
            args.pop(task.arg_names.size)
            task.opts = nil
          end
        end
      end

      return new_scope
    end

    # Expand flat task list in to hierarchy (non-recursive)
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
