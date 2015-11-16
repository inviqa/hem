module Hem
  class << self
    attr_accessor :ui
  end

  class Ui
    include Hem::Logging

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
      return @output_io.tty? unless Hem.windows?
      return (ENV['ANSICON'] || ENV['TERM'] == 'xterm') && @output_io.tty? # ANSICON or MinTTY && output is TTY
    end

    def use_color opt = nil
      HighLine.use_color = opt unless opt.nil?
      HighLine.use_color?
    end

    def ask question, opts = {}
      opts = {
        :validate => nil,
        :default => nil,
        :echo => true
      }.merge(opts)

      unless @interactive
        raise Hem::NonInteractiveError.new(question) if opts[:default].nil?
        return opts[:default].to_s
      end

      question = "#{question} [#{opts[:default]}]" if opts[:default]
      question += ": "
      begin
        answer = @out.ask(question) do |q|
          q.validate = opts[:validate] if opts[:validate]
          q.echo = opts[:echo]
          q.readline
        end
        answer = answer.to_s
        answer.strip.empty? ? opts[:default].to_s : answer.strip
      rescue EOFError
        Hem.ui.info ""
        ""
      end
    end

    def ask_choice question, choices, opts = {}
      unless @interactive
        raise Hem::NonInteractiveError.new(question) if opts[:default].nil?
        return opts[:default].to_s
      end

      question = "#{question} [#{opts[:default]}]" if opts[:default]
      question += ":"
      info question

      choice_map = {}
      choices.to_enum.with_index(1) do |choice, index|
        choice_map[index.to_s] = choice
        info "#{index}] #{choice}"
      end

      begin
        answer = @out.ask("?  ") do |q|
          q.validate = lambda do |a|
            s = a.strip
            s.empty? || (choice_map.keys + choices).include?(s)
          end
          q.readline
        end
        answer = answer.to_s
        answer = choice_map[answer] if /^\d+$/.match(answer.strip)
        answer.strip.empty? ? opts[:default].to_s : answer.strip
      rescue EOFError
        Hem.ui.info ""
        ""
      end
    end

    def editor initial_text
      editor = Hem.user_config.editor.nil? ? ENV['EDITOR'] : Hem.user_config.editor
      if editor.nil?
        raise Hem::UndefinedEditorError.new
      end

      tmp = Tempfile.new('hem_tmp')
      begin
        tmp.write initial_text
        tmp.close
        system([editor, tmp.path].join(' '))
        tmp.open
        return tmp.read
      rescue Exception => e
        raise Hem::Error.new e.message
      ensure
        tmp.close
        tmp.unlink
      end
    end

    def section title
      Hem.ui.title title
      yield
      Hem.ui.separator
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

    def output message
      say @out, message, nil
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
