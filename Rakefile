require 'bundler'
Bundler::GemHelper.install_tasks

ENV['HOBO_BUILD'] = '1'

desc "Build and install"
task :build_install => [:build, :install]
