module Hobo
  class << self
    attr_accessor :ui
  end

  class Ui
    include Hobo::Logging

    attr_accessor :interactive

    COLORS = {
      :debug => [ ],
      :info => [ ],
      :warning => [:yellow],
      :error => [:red],
      :success => [:green],
      :opt => [:green],
      :command => [:green],
      :special => [:blue],
      :title => [:green],
      :help_title => [:yellow],
      :description => [:bold]
    }

    def initialize input = $stdin, output = $stdout, error = $stderr
      HighLine.color_scheme = HighLine::ColorScheme.new COLORS
      @output_io = output
      @out = ::HighLine.new input, output
      @error = ::HighLine.new input, error
      use_color supports_color?
    end

    def color_scheme scheme = nil
      HighLine.color_scheme = scheme if scheme
      HighLine.color_scheme
    end

    def supports_color?
      return @output_io.tty? unless Hobo.windows?
      return (ENV['ANSICON'] || ENV['TERM'] == 'xterm') && @output_io.tty? # ANSICON or MinTTY && output is TTY
    end

    def use_color opt = nil
      HighLine.use_color = opt unless opt.nil?
      HighLine.use_color?
    end

    def ask question, opts = {}
      opts = {
        :validate => nil,
        :default => nil
      }.merge(opts)

      unless @interactive
        raise Hobo::NonInteractiveError.new(question) if opts[:default].nil?
        return opts[:default].to_s
      end

      question = "#{question} [#{opts[:default]}]" if opts[:default]
      question += ": "
      begin
        answer = @out.ask(question) do |q|
          q.validate = opts[:validate] if opts[:validate]
          q.readline
        end
        answer = answer.to_s
        answer.strip.empty? ? opts[:default].to_s : answer.strip
      rescue EOFError
        Hobo.ui.info ""
        ""
      end
    end

    def section title
      Hobo.ui.title title
      yield
      Hobo.ui.separator
    end

    def separator
      info(supports_color? ? "" : "\n")
    end

    def color *args
      @out.color *args
    end

    def debug message
      say @out, message, :debug
    end

    def info message
      say @out, message, :info
    end

    def warning message
      say @error, message, :warning
    end

    def error message
      say @error, message, :error
    end

    def success message
      say @out, message, :success
    end

    def title message
      say @out, message, :title
    end

    private

    def say channel, message, color
      return if message.nil?
      message = color ? channel.color(message, color) : message
      channel.say(message) unless logger.level <= Logger::DEBUG
      logger.debug(message)
    end
  end
end
