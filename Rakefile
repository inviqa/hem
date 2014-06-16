require 'bundler'
Bundler::GemHelper.install_tasks

ENV['HOBO_BUILD'] = '1'

desc "Build and install"
task :build_install => [:build, :install]

desc "Install dev deps"
task :install_dev_deps do
  sh 'rm -rf .bundle/config'
  sh 'HOBO_ENV=dev bundle install'
end

namespace :test do
  task :specs => [ 'install_dev_deps' ] do
    sh 'HOBO_ENV=dev bundle exec rspec'
  end

  task :acceptance => [ 'install_dev_deps' ] do
    sh 'HOBO_ENV=dev bundle exec cucumber'
  end
end
