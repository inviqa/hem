# Hack to override Gemfile to that of hobo (otherwise it'll use project specific one!)
ENV['BUNDLE_GEMFILE'] = File.expand_path('../../../../Gemfile', __FILE__)

require 'shellwords'

begin
  Bundler.setup(:default)
rescue Bundler::GemNotFound => exception
  Hobo::Bundler.install_missing_dependencies
end
