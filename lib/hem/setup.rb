if defined?(Bundler)
  Bundler.with_clean_env do
    exec [$PROGRAM_NAME,$PROGRAM_NAME], *ARGV
  end
end

require_relative 'version'
require_relative 'plugins'

$:.push File.expand_path(File.join("..", ".."), __FILE__)
require 'bundler'
require 'hem'
