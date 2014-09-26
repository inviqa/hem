require 'fileutils'

# Ideally this will be loaded from the omnibus hobo deploy
# Not doing so will mean that stubs will need to be updated when new versions update the stub template (bugfixes etc)

Gem.post_install do |installer|
  template = '#!/usr/bin/env ruby

def project_path
  dir = Dir.pwd.split("/").reverse
  min_length = Gem.win_platform? ? 1 : 0

  while dir.length > min_length
    test_dir = dir.reverse.join("/")

    match = [
      File.exists?(File.join(test_dir, "Hobofile")),
      File.exists?(File.join(test_dir, "tools", "hobo")),
      File.exists?(File.join(test_dir, "tools", "vagrant", "Vagrantfile"))
    ] - [false]

    return test_dir if match.length > 0

    dir.shift
  end
  return nil
end

executable = File.basename __FILE__
project = project_path()

if project
  candidate = File.join(project, ".bundle", "bin", executable)
  exec(candidate, *ARGV) if File.exists? candidate
end

#FIXME wont work on teh winowze
#FIXME has potential for loopyloop; need to make sure located executable isnt this one
exec `which #{executable}`.strip, *ARGV
'
  bin_dir = File.expand_path('~/.hobo/bin')
  installer.spec.executables.each do |file|
    FileUtils.mkdir_p(bin_dir)
    File.write("#{bin_dir}/#{file}", template)
    FilUtils.chmod("#{bin_dir}/#{file}", 0755)
  end
end
