require 'fileutils'

Given(/^"(.*?)" is appended to the (.*) environment variable$/) do |value, env|
  set_env(env, (ENV[env] || "") + ":" + value)
  puts ENV[env]
end
