require 'fileutils'

Given(/^there is a seed called "(.*?)" with:$/) do |seed, contents|
  create_dir(seed)
  cd(seed)
  write_file("test", contents)
  run_simple(unescape("git init"))
  run_simple(unescape("git add *"))
  run_simple(unescape("git commit -m 'init'"))
  cd('..')
end