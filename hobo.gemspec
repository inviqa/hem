# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'hobo/version'

Gem::Specification.new do |spec|
  spec.name          = "hobo-inviqa"
  spec.version       = Hobo::VERSION.gsub('-', '.pre.')
  spec.authors       = ["Mike Simons"]
  spec.email         = ["msimons@inviqa.com"]
  spec.description   = %q{Inviqan toolbelt}
  spec.summary       = %q{Inviqan toolbelt}
  spec.homepage      = ""

  # This file will get interpretted at runtime due to Bundler.setup
  # Without the $HOBO_ARGV check (set in bin/hobo) fatal: not a git repository errors show up
  spec.files         = `git ls-files`.split($/) if ENV['HOBO_BUILD'] == '1'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "slop", "~> 3.4.7"
  spec.add_dependency "highline", "~> 1.6.20"
  spec.add_dependency "rake", "~> 10.1.1"
  spec.add_dependency "bundler", ">= 1.5.2"
  spec.add_dependency "deepstruct", "~> 0.0.5"
  spec.add_dependency "semantic", "~> 1.3.0"
  spec.add_dependency "aws-sdk", "~> 1.34.0"
  spec.add_dependency "ruby-progressbar", "~> 1.4.1"
  spec.add_dependency "teerb", "~> 0.0.1"
  spec.add_dependency "net-ssh-simple", "~> 1.6.3"
  spec.add_dependency "pry", "~> 0.9.12"

  # This prevents Bundler.setup from complaining that rubygems did not install dev deps
  # If you want to run dev deps you need to ensure HOBO_ENV=dev is set for bundle install & bundle exec
  if ENV['HOBO_ENV'] == 'dev'
    spec.add_development_dependency "aruba", "~> 0.5.4"
    spec.add_development_dependency "rspec", "~> 2.14.1"
    spec.add_development_dependency "fakefs", "~> 0.5.0"
    spec.add_development_dependency "rr", "~> 1.1.2"
    spec.add_development_dependency "guard", "~> 2.2.5"
    spec.add_development_dependency "guard-rspec", "~> 4.2.4"
    spec.add_development_dependency "guard-cucumber", "~> 1.4.1"
    spec.add_development_dependency "simplecov", "~> 0.7.1"
  end
end
