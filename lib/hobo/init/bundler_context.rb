# Hack to override Gemfile to that of hobo (otherwise it'll use project specific one!)
ENV['BUNDLE_GEMFILE'] = File.expand_path('../../../../Gemfile', __FILE__)

require 'shellwords'
require 'hobo/version'

# gem install != bundle install
# Gem may well skip some deps that bundler wants
bundler_check = File.join(ENV['HOME'], '.hobo', 'bundler_check')
unless File.exists?(bundler_check) && File.read(bundler_check).strip == Hobo::VERSION
  `bundle check --gemfile=#{ENV['BUNDLE_GEMFILE'].shellescape}`
  unless $?.success?
    puts "Hobo has detected missing dependencies. Please wait while they're installed"
    `bundle install --gemfile=#{ENV['BUNDLE_GEMFILE'].shellescape}`
    Kernel.exec('hobo', *$HOBO_ARGV)
  end
  File.write(bundler_check, Hobo::VERSION)
end

require 'hobo/patches/rubygems'
require 'bundler'

Bundler.setup(:default)
