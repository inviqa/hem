# External deps
require 'slop'
require 'rake'
require 'rake/hooks'
require 'tempfile'
require 'shellwords'
require 'deepstruct'
require 'logger'
require 'highline'
require 'fileutils'

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
require 'hobo/logging'
require 'hobo/ui'
require 'hobo/util'
require 'hobo/help_formatter'
require 'hobo/error_handlers/exit_code_map'
require 'hobo/error_handlers/debug'
require 'hobo/error_handlers/friendly'
require 'hobo/config/file'
require 'hobo/config'

# Asset sync
require 'hobo/lib/s3/sync'
require 'hobo/lib/s3/local/file'
require 'hobo/lib/s3/local/iohandler'
require 'hobo/lib/s3/remote/file'
require 'hobo/lib/s3/remote/iohandler'

# Task helpers
require 'hobo/helper/shell'
require 'hobo/helper/file_locator'
require 'hobo/helper/http_download'
require 'hobo/helper/vm_command'

require 'hobo/lib/vm/inspector'
require 'hobo/lib/vm/command'

# Asset applicators
require 'hobo/asset_applicator'
require 'hobo/asset_applicators/sqldump'
require 'hobo/asset_applicators/files'

# Libs
require 'hobo/lib/seed/project'
require 'hobo/lib/seed/replacer'
require 'hobo/lib/seed/seed'

# Host checks
require 'hobo/lib/host_check/git'
require 'hobo/lib/host_check/vagrant'
require 'hobo/lib/host_check/ruby'
require 'hobo/lib/host_check/deps'
require 'hobo/lib/host_check/hobo'
require 'hobo/lib/host_check'

# App
require 'hobo/cli'