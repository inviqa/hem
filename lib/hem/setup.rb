if defined?(Bundler)
  Bundler.with_clean_env do
    exec [$PROGRAM_NAME,$PROGRAM_NAME], *ARGV
  end
end

require_relative 'version'
require_relative 'plugins'

if ENV['HEM_OMNIBUS']
  $:.push File.expand_path(File.join("..", ".."), __FILE__)
else
  gem 'hem', Hem::VERSION
end

require 'bundler'
require_relative '../hem'
