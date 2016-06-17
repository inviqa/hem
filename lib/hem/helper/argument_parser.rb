module Hem
  module Helper
    def convert_args task_name, args, arg_list
      original_args = args.dup
      task_args = []
      arg_list.each do |_, options|
        if args.empty?
          if !options[:optional]
            raise ::Hem::MissingArgumentsError.new(task_name, original_args)
          else
            task_args << options[:default]
          end
        elsif options[:as] == Array
          task_args << args.dup
          args.clear
        else
          task_args << args.shift
        end
      end

      unless args.empty?
        raise ::Hem::InvalidCommandOrOpt.new(args.join(' '))
      end

      task_args
    end
  end
end

self.extend Hem::Helper