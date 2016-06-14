if defined?(Bundler)
  Bundler.with_clean_env do
    exec [$PROGRAM_NAME,$PROGRAM_NAME], *ARGV
  end
end

require_relative 'version'
require_relative 'plugins'

gem 'hem', Hem::VERSION unless ENV['HEM_OMNIBUS']

require 'bundler'
require 'hem'
