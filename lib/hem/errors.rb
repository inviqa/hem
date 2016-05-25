module Hem
  class Error < StandardError
    attr_reader :exit_code
  end
  
  class HemVersionError < Error
    def initialize requirements
      super("
This Hem project has specified that it requires the Hem
version to satisfy the following version requirements:
  #{requirements.join("\n")}
You are running Hem #{VERSION}, which does not satisfy
these requirements. Please upgrade Hem to the latest
version, or relax the Hemfile's version constraints if
you're already using the latest Hem version.")
    end
  end

  class RubyVersionError < Error
    def initialize
      super("Ruby 1.9+ is required to run hem")
    end
  end

  class MissingDependencies < Error
    def initialize deps
      deps.map! { |dep| " - #{dep}"}
      super("Hem requires the following commands to be available on your path:\n\n" + deps.join("\n"))
    end
  end

  class InvalidCommandOrOpt < Error
    attr_accessor :command
    def initialize command
      @command = command
      super("Invalid command or option specified: '#{command}'")
    end
  end

  class MissingArgumentsError < Error
    attr_accessor :command
    def initialize command, args
      @command = command
      @args = args
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
      super("A task requested input from the user but hem is in non-interactive mode")
    end
  end

  class MissingDependency < Error
    def initialize dep
      @dependency = dep
      super("A tool that hem depends on could not be detected (#{dep})")
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

  class UndefinedEditorError < Error
    def initialize
      super('You need to define a preferred editor, either in your hem config or with the EDITOR environment variable')
    end
  end
end
