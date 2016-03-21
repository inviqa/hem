unless defined? HOBO_TASKS_MAGENTO_DEPRECATION
Hem.ui.warning "require 'hem/tasks/magento' in #{Hem.project_dsl_file} is deprecated, and will be removed in a future release."
end

Hem.ui.warning <<-eos
Please replace with:

Hem.require_version '~> 1.1'

plugins do
  gem 'hem-tasks-magento1', '~> 1.0'
end
eos

plugins do
  gem 'hem-tasks-magento1', '~> 1.0'
end
