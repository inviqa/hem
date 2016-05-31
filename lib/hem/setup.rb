require 'bundler'
require_relative 'version'
require_relative 'plugins'

$:.push File.expand_path(File.join("..", ".."), __FILE__)
require 'hem'
