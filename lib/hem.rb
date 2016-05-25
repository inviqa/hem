# External deps
require 'slop'
require 'rake'
require 'deepstruct'
require 'logger'
require 'json'

require 'shellwords'
require 'fileutils'

# DSL enhancements
require_relative 'hem/metadata'
require_relative 'hem/patches/rake'
require_relative 'hem/patches/slop'
require_relative 'hem/patches/deepstruct'

# Basics
require_relative 'hem/version'
require_relative 'hem/null'
require_relative 'hem/paths'
require_relative 'hem/errors'
require_relative 'hem/logging'
require_relative 'hem/plugins'
require_relative 'hem/ui'
require_relative 'hem/util'
require_relative 'hem/help_formatter'
require_relative 'hem/error_handlers/exit_code_map'
require_relative 'hem/error_handlers/debug'
require_relative 'hem/error_handlers/friendly'
require_relative 'hem/config/file'
require_relative 'hem/config'

# Asset sync
require_relative 'hem/lib/s3/sync'
require_relative 'hem/lib/s3/local/file'
require_relative 'hem/lib/s3/local/iohandler'
require_relative 'hem/lib/s3/remote/file'
require_relative 'hem/lib/s3/remote/iohandler'

# Task helpers
require_relative 'hem/helper/argument_parser'
require_relative 'hem/helper/command'
require_relative 'hem/helper/shell'
require_relative 'hem/helper/file_locator'
require_relative 'hem/helper/github'
require_relative 'hem/helper/http_download'
require_relative 'hem/helper/vm_command'

require_relative 'hem/lib/local/command'

require_relative 'hem/lib/vm/inspector'
require_relative 'hem/lib/vm/command'

# Asset applicators
require_relative 'hem/asset_applicator'
require_relative 'hem/asset_applicators/sqldump'
require_relative 'hem/asset_applicators/files'

# Libs
require_relative 'hem/lib/seed/project'
require_relative 'hem/lib/seed/replacer'
require_relative 'hem/lib/seed/seed'
require_relative 'hem/lib/seed/template'
require_relative 'hem/lib/self_signed_cert_generator'

# Host checks
require_relative 'hem/lib/host_check/git'
require_relative 'hem/lib/host_check/vagrant'
require_relative 'hem/lib/host_check/deps'
require_relative 'hem/lib/host_check'

# App
require_relative 'hem/cli'

# Hobo BC
Hobo = Hem
