require 'simplecov'

SimpleCov.start do
  add_filter "spec/"
end

require 'hem'
require 'fakefs/safe'

RSpec.configure do |c|
  c.treat_symbols_as_metadata_keys_with_true_values = true
end
