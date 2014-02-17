require 'slop'
require 'highline'
require 'hobo/ui'
require 'hobo/patches/slop'

module Hobo
  class HelpFormatter
    attr_accessor :command_map
    ALIGN_PAD = 4

    def initialize global
      @global = global
      @command_map = {}
    end

    def help opts = {}
      target = opts[:target] || nil
      output = [""]

      command = @command_map[target]

      if !command
        command_opts = []
        commands = commands_for(@global, opts)
        command = @global
      else
        command_opts = options_for(command)
        commands = commands_for(command, opts)
      end

      global_opts = options_for(@global)

      align_to = longest([global_opts, command_opts, commands]) + ALIGN_PAD

      if command != @global
        description = [ command.long_description, command.description ].compact.first
        output.push Hobo.ui.color("#{description}\n", :description) if description
      end

      output.push section("Usage", [usage(command, target)])
      output.push section("Global options", global_opts, align_to)
      output.push section("Command options", command_opts, align_to)
      output.push section("Commands", commands, align_to)

      return output.compact.join("\n")
    end

    private

    def longest inputs
      inputs.map do |input|
        next unless input.is_a? Array
        if input.size == 0
          0
        else
          input.map(&:first).map(&:size).max
        end
      end.compact.max
    end

    def options_for source
      heads  = source.options.reject(&:tail?)
      tails  = (source.options - heads)

      (heads + tails).map do |opt|
        next if source != @global && opt.short == 'h'
        line = padded(opt.short ? "-#{opt.short}," : "", 4)
        description = opt.description

        if opt.long
          description += ". (Disable with --no-#{opt.long})" if opt.config[:invertable]
          value = opt.config[:argument] ? "#{opt.long.upcase}" : ""
          value = "[#{value}]" if opt.accepts_optional_argument?
          value = "=#{value}" unless value.empty?

          line += "--#{opt.long}#{value}"
        end

        [Hobo.ui.color(line, :opt), description]
      end.compact
    end

    def commands_for source, opts = {}
      source.commands.map do |name, command|
        next if command.hidden && !opts[:all]
        next unless command.hidden == false || command.description || opts[:all]
        [Hobo.ui.color(name, :command), command.description]
      end.compact
    end

    def usage source, command = nil
      banner = source.banner
      if banner.nil?
        arg_list = (source.arg_list || []).map do |arg|
          "<#{arg}>"
        end

        banner = "#{File.basename($0, '.*')}"
        banner << " [command]" if source.commands.any? && command.nil?
        banner << " #{command.split(':').join(' ')}" if command
        banner << " #{arg_list.join(' ')}" if arg_list.size > 0
        banner << " [options]"
      end
    end

    def section title, contents, align_to = false
      return nil if contents.empty?
      output = Hobo.ui.color("#{title}:\n", :help_title)
      output += contents.map do |line|
        line.is_a?(String) ? "  #{line}" : "  #{padded(line[0], align_to)}#{line[1]}"
      end.join("\n") + "\n"
    end

    def padded str, target
      str + (' ' * (target - str.size))
    end
  end
end