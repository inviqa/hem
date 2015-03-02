require 'bundler'
require 'json'
Bundler::GemHelper.install_tasks

ENV['HOBO_BUILD'] = '1'

desc "Build and install"
task :build_install => [:build, :install]

desc "Install dev deps"
task :install_dev_deps do
  sh 'rm -rf .bundle/config'
  sh 'HOBO_ENV=dev bundle install'
end

task 'install-isolated' do
  Rake::Task['build'].invoke
  #load 'lib/hobo/version.rb'
  exec({
    'GEM_HOME' => File.expand_path('~/.hobo/gems'),
    'GEM_PATH' => File.expand_path('~/.hobo/gems')
    },
    "gem install --no-ri --no-rdoc pkg/hobo-inviqa-#{Hobo::VERSION.gsub('-', '.pre.')}.gem"
  )
end

namespace :test do
  task :specs => [ 'install_dev_deps' ] do
    sh 'HOBO_ENV=dev bundle exec rspec'
  end

  task :acceptance => [ 'install_dev_deps' ] do
    sh 'HOBO_ENV=dev bundle exec cucumber'
  end
end

desc "Generate gemlocked file"
task :gemlock do
  exec({'GEMLOCK' => '1' }, "rake gemlock") if !ENV['GEMLOCK']
  sh 'bundle install'
  Bundler.setup
  gems = {}
  Gem::Specification.each do |spec|
    next if spec.name == 'hobo-inviqa'
    gems[spec.name] = spec.version.to_s
  end
  File.write "Gemlock", JSON.dump(gems)
end
