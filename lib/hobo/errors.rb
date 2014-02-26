module Hobo
  class Error < StandardError
    attr_reader :exit_code
  end

  class RubyVersionError < Error
    def initialize
      super("Ruby 1.9+ is required to run hobo")
    end
  end

  class MissingDependencies < Error
    def initialize deps
      deps.map! { |dep| " - #{dep}"}
      super("Hobo requires the following commands to be available on your path:\n\n" + deps.join("\n"))
    end
  end

  class InvalidCommandOrOpt < Error
    attr_accessor :command, :cli
    def initialize command, cli = nil
      @command = command
      @cli = cli
      super("Invalid command or option specified: '#{command}'")
    end
  end

  class MissingArgumentsError < Error
    attr_accessor :command, :cli
    def initialize command, args, cli = nil
      @command = command
      @args = args
      @cli = cli
      super("Not enough arguments for #{command}")
    end
  end

  class ExternalCommandError < Error
    attr_accessor :command, :exit_code, :output

    def initialize command, exit_code, output
      @command = command
      @exit_code = exit_code
      @output = output
      super("'#{command}' returned exit code #{exit_code}")
    end
  end

  class UserError < Error
  end

  class ProjectOnlyError < Error
  end

  class NonInteractiveError < Error
    def initialize question
      @question = question
      super("A task requested input from the user but hobo is in non-interactive mode")
    end
  end

  class MissingDependency < Error
    def initialize dep
      @dependency = dep
      super("A tool that hobo depends on could not be detected (#{dep})")
    end
  end

  class HostCheckError < Error
    attr_accessor :summary, :advice
    def initialize summary, advice
      @summary = summary
      @advice = advice
      super("Host check failed: #{summary}")
    end
  end
end
