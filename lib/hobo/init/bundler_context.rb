# Hack to override Gemfile to that of hobo (otherwise it'll use project specific one!)
ENV['BUNDLE_GEMFILE'] = File.expand_path('../../../../Gemfile', __FILE__)

require 'shellwords'

begin
  Bundler.setup(:default)
rescue Bundler::GemNotFound => e
  puts 'Missing dependencies detected!'
  print 'These will automatically be installed now, please wait'
  rval = nil
  IO::popen("bundle install --gemfile=#{ENV['BUNDLE_GEMFILE'].shellescape}") do |io|
    while line = io.gets
      print '.'
    end
    puts ' done'
    io.close
    rval = $?.to_i
  end

  if rval == 0
    Kernel.exec('hobo', *$HOBO_ARGV)
  else
    puts
    puts "Failed to install dependencies. Hobo can not proceed."
    puts "Please see the error below:"
    puts
    throw e
  end
end
