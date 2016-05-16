require 'bundler'
require_relative 'version'
require_relative 'plugins'

Hem::Plugins.new(__dir__, '.noGemfile', false).define do
  gem 'hem', Hem::VERSION, :path => File.expand_path(File.join('..', '..', '..'), __FILE__)
end.require
