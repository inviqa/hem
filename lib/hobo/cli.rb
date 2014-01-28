module Hobo

  class Halt < Error
  end

  class Cli
    attr_accessor :slop, :help_formatter

    def initialize opts = {}
      @opts = opts
      @slop = opts[:slop] || Slop.new
      @help_formatter = opts[:help] || Hobo::HelpFormatter.new(@slop)
      @help_opts = {}
    end

    def start argv = ARGV
      load_hobofile

      tasks = structure_tasks Hobo::Metadata.metadata.keys
      args = fix_args_with_equals argv
      define_global_opts @slop

      begin
        # Parse out global args first
        @slop.parse! args
        opts = @slop.to_hash
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

    def load_hobofile
      if Hobo.in_project? && File.exists?(Hobo.hobofile_path)
        load Hobo.hobofile_path
      end
    end

    def define_global_opts slop
      slop.on '--debug', 'Enable debugging'
      slop.on '-a', '--all', 'Show hidden commands'
      slop.on '-h', '--help', 'Display help'
      slop.on '--non-interactive', 'Run non-interactively. Defaults will be automaticall used where possible.'

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
            raise ::Hobo::ProjectOnlyError.new if opts.project_only && !Hobo.in_project?
            task.opts = opts.to_hash
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

    # Slop badly handles assignment args passed as --arg=val
    # This hack fixes that by making them --arg val
    def fix_args_with_equals args
      items = []
      args.each do |item|
        if item.match /^-.*\=/
          item.split('=').each { |i| items.push i }
        else
          items.push item
        end
      end
      return items
    end
  end
end