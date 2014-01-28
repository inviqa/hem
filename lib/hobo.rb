# External deps
require 'rake'
require 'rake/hooks'
require 'slop'
require 'highline'
require 'open3'
require 'tempfile'
require 'shellwords'
require 'find'

# DSL enhancements
require 'hobo/metadata'
require 'hobo/patches/rake'
require 'hobo/patches/slop'

# Task helpers
require 'hobo/helper/shell'
require 'hobo/helper/file_locator'

# Basics
require 'hobo/version'
require 'hobo/paths'
require 'hobo/errors'
require 'hobo/ui'
require 'hobo/util'
require 'hobo/help_formatter'
require 'hobo/error_handlers/debug'
require 'hobo/error_handlers/friendly'
require 'hobo/config/file'

# Libs
require 'hobo/lib/seed/project'
require 'hobo/lib/seed/replacer'
require 'hobo/lib/seed/seed'

# Built-in tasks
require 'hobo/tasks/debug'
require 'hobo/tasks/deps'
require 'hobo/tasks/seed'
require 'hobo/tasks/vm'
require 'hobo/tasks/tools'

# App
require 'hobo/cli'