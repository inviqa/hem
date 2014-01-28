# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'hobo/version'

Gem::Specification.new do |spec|
  spec.name          = "hobo-inviqa"
  spec.version       = Hobo::VERSION
  spec.authors       = ["Mike Simons"]
  spec.email         = ["msimons@inviqa.com"]
  spec.description   = %q{Inviqan toolbelt}
  spec.summary       = %q{Inviqan toolbelt}
  spec.homepage      = ""

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  # TODO pin
  spec.add_dependency "slop"
  spec.add_dependency "highline"
  spec.add_dependency "rake"
  spec.add_dependency "rake-hooks"
  spec.add_dependency "bundler"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "aruba"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "fakefs"
  spec.add_development_dependency "rr"
  spec.add_development_dependency "guard", "~> 2.2.5"
  spec.add_development_dependency "guard-rspec", "~> 4.2.4"
  spec.add_development_dependency "guard-cucumber", "~> 1.4.1"
end
