# External deps
require 'rake'
require 'rake/hooks'
require 'tempfile'
require 'shellwords'
require 'deepstruct'

# DSL enhancements
require 'hobo/metadata'
require 'hobo/patches/rake'
require 'hobo/patches/slop'
require 'hobo/patches/deepstruct'

# Basics
require 'hobo/version'
require 'hobo/null'
require 'hobo/paths'
require 'hobo/errors'
require 'hobo/ui'
require 'hobo/util'
require 'hobo/help_formatter'
require 'hobo/error_handlers/debug'
require 'hobo/error_handlers/friendly'
require 'hobo/config/file'
require 'hobo/logging'
require 'hobo/config'
require 'hobo/asset_applicator'

# Task helpers
require 'hobo/helper/shell'
require 'hobo/helper/file_locator'
require 'hobo/helper/vm_command'

# Libs
require 'hobo/lib/seed/project'
require 'hobo/lib/seed/replacer'
require 'hobo/lib/seed/seed'

# Host checks
require 'hobo/lib/host_check/git'
require 'hobo/lib/host_check/vagrant'
require 'hobo/lib/host_check/ruby'
require 'hobo/lib/host_check/deps'
require 'hobo/lib/host_check'

# App
require 'hobo/cli'