module Rake
  class Task
    attr_accessor :opts
    def opts
      @opts = @opts || {}
    end
  end

  module DSL
    def before(task_name, new_tasks = nil, &new_task)
      task_name = task_name.to_s
      new_tasks = [new_tasks].flatten.compact
      old_task = Rake.application.instance_variable_get('@tasks').delete(task_name)

      Hem::Metadata.to_store task_name
      task task_name => old_task.prerequisites do
        new_task.call unless new_task.nil?
        new_tasks.each do |t|
          Rake::Task[t].invoke
        end
        old_task.invoke
      end
    end

    def after(task_name, new_tasks = nil, &new_task)
      task_name = task_name.to_s
      new_tasks = [new_tasks].flatten.compact
      old_task = Rake.application.instance_variable_get('@tasks').delete(task_name)

      Hem::Metadata.to_store task_name
      task task_name => old_task.prerequisites do
        old_task.invoke
        new_tasks.each do |t|
          Rake::Task[t].invoke
        end
        new_task.call unless new_task.nil?
      end
    end

    def replace *args, &block
      old = (args[0].is_a? Hash) ? args[0].keys[0] : args[0]
      Hem::Logging.logger.debug("rake.dsl: Replacing #{old} with block")
      Rake::Task[old].clear
      task(*args, &block)
    end

    def invoke task, *args, &block
      Rake::Task[task].invoke(*args, &block)
    end

    def argument name, options = {}
      opts = {
        optional: false,
        as: String,
      }.merge(options)
      Hem::Metadata.store[:arg_list] ||= {}

      if Hem::Metadata.store[:arg_list].length > 0
        last_arg = Hem::Metadata.store[:arg_list].values.last
        if last_arg[:optional] && !opts[:optional]
          raise 'Cannot have mandatory arguments after optional arguments'
        elsif last_arg[:as] == Array
          raise 'Cannot add any arguments after an array argument'
        end
      end

      Hem::Metadata.store[:arg_list][name] = opts
    end

    def hidden value = true
      Hem::Metadata.store[:hidden] = value
    end

    def project_only
      Hem::Metadata.store[:project_only] = true
    end

    def task *args, &block
      name = args[0].is_a?(Hash) ? args[0].keys.first.to_s : args[0]
      scoped_name = Rake.application.current_scope.path_with_task_name(name).to_s
      Hem::Metadata.store[:arg_list] ||= {}

      args[1..-1].each do |name|
        argument name, optional: true
      end if args.length > 1

      [:opts, :desc, :long_desc, :hidden, :project_only, :arg_list].each do |meta|
        Hem::Metadata.add scoped_name, meta
      end

      if Hem::Metadata.store[:arg_list]
        args = [args[0], *Hem::Metadata.store[:arg_list].keys]
      end

      Hem::Metadata.reset_store

      Hem::Logging.logger.debug("Added metadata to #{scoped_name} -- #{Hem::Metadata.metadata[scoped_name]}")

      task = Rake::Task.define_task(*args, &block)
    end

    def option *args
      Hem::Metadata.store[:opts].push args
    end

    def desc description
      Hem::Metadata.store[:desc] = description
    end

    def long_desc description
      Hem::Metadata.store[:long_desc] = description
    end

    alias :_old_namespace :namespace
    def namespace name, opts = {}, &block
      scoped_name = Rake.application.current_scope.path_with_task_name(name).to_s
      [:desc, :long_desc, :hidden, :project_only].each do |meta|
        Hem::Metadata.add scoped_name, meta
      end

      Hem::Metadata.reset_store

      _old_namespace(name, &block)
    end

    def plugins &block
      Hem.plugins.define &block
    end
  end
end

Hem::Metadata.default :opts, []
Hem::Metadata.default :desc, nil
