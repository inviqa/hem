# External deps
require 'slop'
require 'rake'
require 'tempfile'
require 'shellwords'
require 'deepstruct'
require 'logger'
require 'highline'
require 'fileutils'
require 'openssl'
require 'octokit'

# DSL enhancements
require 'hem/metadata'
require 'hem/patches/rake'
require 'hem/patches/slop'
require 'hem/patches/deepstruct'

# Basics
require 'hem/version'
require 'hem/null'
require 'hem/paths'
require 'hem/errors'
require 'hem/logging'
require 'hem/ui'
require 'hem/util'
require 'hem/help_formatter'
require 'hem/error_handlers/exit_code_map'
require 'hem/error_handlers/debug'
require 'hem/error_handlers/friendly'
require 'hem/config/file'
require 'hem/config'

# Asset sync
require 'hem/lib/s3/sync'
require 'hem/lib/s3/local/file'
require 'hem/lib/s3/local/iohandler'
require 'hem/lib/s3/remote/file'
require 'hem/lib/s3/remote/iohandler'

# Task helpers
require 'hem/helper/shell'
require 'hem/helper/file_locator'
require 'hem/helper/github'
require 'hem/helper/http_download'
require 'hem/helper/vm_command'

require 'hem/lib/vm/inspector'
require 'hem/lib/vm/command'

# Asset applicators
require 'hem/asset_applicator'
require 'hem/asset_applicators/sqldump'
require 'hem/asset_applicators/files'

# Libs
require 'hem/lib/seed/project'
require 'hem/lib/seed/replacer'
require 'hem/lib/seed/seed'
require 'hem/lib/self_signed_cert_generator'
require 'hem/lib/github/api'
require 'hem/lib/github/client'

# Host checks
require 'hem/lib/host_check/git'
require 'hem/lib/host_check/vagrant'
require 'hem/lib/host_check/ruby'
require 'hem/lib/host_check/deps'
require 'hem/lib/host_check/hem'
require 'hem/lib/host_check'

# App
require 'hem/cli'

# Hobo BC
Hobo = Hem
