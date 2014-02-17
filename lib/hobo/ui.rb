require 'highline'

module Hobo
  class << self
    attr_accessor :ui
  end

  class Ui
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

    def initialize out = $stdout, error = $stderr
      HighLine.color_scheme = HighLine::ColorScheme.new COLORS
      @out = ::HighLine.new $stdin, out
      @error = ::HighLine.new $stdin, error
    end

    def color_scheme scheme = nil
      HighLine.color_scheme = scheme if scheme
      HighLine.color_scheme
    end

    def use_color opt = nil
      HighLine.use_color = opt unless opt.nil?
      HighLine.use_color?
    end

    def ask question, opts = {}
      unless Hobo.ui.interactive
        raise Hobo::NonInteractive.new(question) if opts[:default].nil?
        return opts[:default]
      end

      question = "#{question} [#{opts[:default]}]" if opts[:default]
      question += ": "
      begin
        answer = @out.ask(question) do |q|
          q.validate = opts[:validate] if opts[:validate]
          q.readline
        end
        answer.strip.empty? ? opts[:default] : answer.strip
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
      info ""
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
      channel.say(color ? channel.color(message, color) : message)
    end
  end
end