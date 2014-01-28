require 'aruba/cucumber'

Before do
  # bundler / composer features need this
  @aruba_timeout_seconds = 120
end