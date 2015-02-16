module Rake
  class Task
    attr_accessor :opts
    def opts
      @opts = @opts || {}
    end
  end

  module DSL
    def before(task_name, new_tasks = nil, &new_task)
      new_tasks = [new_tasks].flatten.compact
      old_task = Rake.application.instance_variable_get('@tasks').delete(task_name.to_s)

      Hobo::Metadata.to_store task_name
      task task_name => old_task.prerequisites do
        new_task.call unless new_task.nil?
        new_tasks.each do |t|
          Rake::Task[t].invoke
        end
        old_task.invoke
      end
    end

    def after(task_name, new_tasks = nil, &new_task)
      new_tasks = [new_tasks].flatten.compact
      old_task = Rake.application.instance_variable_get('@tasks').delete(task_name.to_s)

      Hobo::Metadata.to_store task_name
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
      Hobo::Logging.logger.debug("rake.dsl: Replacing #{old} with block")
      Rake::Task[old].clear
      task(*args, &block)
    end

    def invoke task, *args, &block
      Rake::Task[task].invoke(*args, &block)
    end

    def hidden value = true
      Hobo::Metadata.store[:hidden] = value
    end

    def project_only
      Hobo::Metadata.store[:project_only] = true
    end

    def task *args, &block
      name = args[0].is_a?(Hash) ? args[0].keys.first.to_s : args[0]
      scoped_name = Rake.application.current_scope.path_with_task_name(name).to_s

      [:opts, :desc, :long_desc, :hidden, :project_only].each do |meta|
        Hobo::Metadata.add scoped_name, meta
      end

      Hobo::Metadata.reset_store

      Hobo::Logging.logger.debug("Added metadata to #{scoped_name} -- #{Hobo::Metadata.metadata[scoped_name]}")

      task = Rake::Task.define_task(*args, &block)
    end

    def option *args
      Hobo::Metadata.store[:opts].push args
    end

    def desc description
      Hobo::Metadata.store[:desc] = description
    end

    def long_desc description
      Hobo::Metadata.store[:long_desc] = description
    end

    alias :_old_namespace :namespace
    def namespace name, opts = {}, &block
      scoped_name = Rake.application.current_scope.path_with_task_name(name).to_s
      [:desc, :long_desc, :hidden, :project_only].each do |meta|
        Hobo::Metadata.add scoped_name, meta
      end

      Hobo::Metadata.reset_store

      _old_namespace(name, &block)
    end
  end
end

Hobo::Metadata.default :opts, []
Hobo::Metadata.default :desc, nil
