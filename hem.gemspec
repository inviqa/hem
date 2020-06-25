# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'hem/version'

Gem::Specification.new do |spec|
  spec.name          = "hem"
  spec.version       = Hem::VERSION
  spec.authors       = ["Mike Simons", "Andy Thompson"]
  spec.email         = ["athompson@inviqa.com"]
  spec.description   = %q{Inviqan toolbelt}
  spec.summary       = %q{Inviqan toolbelt}
  spec.homepage      = ""

  # This file will get interpretted at runtime due to Bundler.setup
  # Without the $HEM_ARGV check (set in bin/hem) fatal: not a git repository errors show up
  spec.files         = `git ls-files`.split($/) if ENV['HEM_BUILD'] == '1'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "aws-sdk", "~> 2.3.8"
  spec.add_dependency "deepstruct", "~> 0.0.7"
  spec.add_dependency "highline", "~> 1.7.3"
  spec.add_dependency "jmespath", "~> 1.1.3"
  spec.add_dependency "json", "~> 1.8.1"
  spec.add_dependency "net-ssh-simple", "~> 1.6.3"
  spec.add_dependency "pry", "~> 0.10.3"
  spec.add_dependency "rake", ">= 11.1.2", "< 13.1.0"
  spec.add_dependency "ruby-progressbar", "~> 1.8.1"
  spec.add_dependency "slop", "~> 3.6.0"
  spec.add_dependency "teerb", "~> 0.0.1"

  # This prevents Bundler.setup from complaining that rubygems did not install dev deps
  # If you want to run dev deps you need to ensure HEM_ENV=dev is set for bundle install & bundle exec
  if ENV['HEM_ENV'] == 'dev'
    spec.add_development_dependency "aruba", "~> 0.5.4"
    spec.add_development_dependency "fakefs", "~> 0.5.0"
    spec.add_development_dependency "guard", "~> 2.2.5"
    spec.add_development_dependency "guard-rspec", "~> 4.2.4"
    spec.add_development_dependency "guard-cucumber", "~> 1.4.1"
    spec.add_development_dependency "rr", "~> 1.1.2"
    spec.add_development_dependency "rspec", "~> 2.14.1"
    spec.add_development_dependency "simplecov", "~> 0.7.1"
  end
end
