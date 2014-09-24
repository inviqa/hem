## 0.0.16 (unreleased)

  * tasks/magento: Set magento secure url to use https
  * tasks/seed: Change the project seed prompt to list available seeds as choices.

## 0.0.15 (5 September 2014)

FEATURES:

  * tasks/magento: **New Hobo task: `hobo magento patches apply`** - Applies official and critical magento patches
  * tasks/seed: custom key-value data can be supplied to project configuration for `hobo seed plant` via `--data` or `-d`
  * core/ui: new Hobo.ui.ask_choice method to give a numbered list of options to choose

BUG FIXES:

  * core/gem_isolation: fix for bundler 1.6.5+ compatibility issue

## 0.0.14 (20 August 2014)

BUG FIXES:

  * tasks/seed: fix typo with home path detection
  * tasks/deps: fix inverted check for disable_host_run in deps:composer

## 0.0.13 (31 July 2014)

BUG FIXES:

  * tasks/deps: fixes spacing bug on new vagrant plugin psuedo syntax

## 0.0.12 (yanked)

FEATURES:
  * tasks/ops: new ops task to generate self signed certs
  * tasks/seed: integrate self signed certs in to seed plant
  * tasks/deps: implemented new psuedo syntax for vagrant plugins to avoid require_plugin warnings

IMPROVEMENTS:

  * tasks/vm: changed vm:stop to use halt instead of suspend
  * tasks/seed: better detection of local paths for seed argument

BUG FIXES:

  * core: minor fixes and enhancements

## 0.0.11 (16 June 2014)

FEATURES:

  * tasks/assets: dry run / confirmation of destructive sync
  * tasks/deps: deps:composer now has option to disable host run of composer at the project level

IMPROVEMENTS:

  * tasks/assets: rewritten mysql asset applicator to better handle error cases
  * core/gem_isolation: refactored in to own module

BUG FIXES:

  * tasks/assets: raise error when we encounter AWS error as VM will not start cleanly

## 0.0.10 (23 May 2014)

FEATURES:

  * core/gem_isolation: Initial implementation
  * tasks/self: repl task to debug adhoc issues in the context of hobo

## 0.0.9 (3 April 2014)

FEATURES:

  * tasks/assets: new asset applicator feature to automatically load assets where possible
  * core/host_checks: latest hobo version check and auto-upgrade prompt
  * tasks/magento: magento specific tasks implemented

IMPROVEMENTS:

  * tasks/assets: restructured asset sync code to multiple files
  * core/util: centralized aws credential retrieval and windows host detection

## 0.0.8 (7 March 2014)

FEATURES:

  * core/debug: implemented debug tee (writes debug to stdout and /tmp/hobo_debug.log)
  * core/cli: implemented argv passthrough
  * tasks/config: new feature to set configuration in ~/.hobo/config.yaml
  * helpers/http_download: new feature to download files from http w/ progressbar support

IMPROVEMENTS:

  * tasks/assets: improved asset sync handler
  * core/host_checks: much improved host check feedback
  * helpers/vm_shell: rewritten to support project mount detection and pull config from vagrant
  * core/errors: refactored error handler support to create consistent error return codes without duplication

## 0.0.7 (18 February 2014)

FEATURES:

  * tasks/seed: introduced submodule support for seeds (specifically magento)

IMPROVEMENTS:

  * tasks/assets: error handling improvements
  * core/errors: friendly formatter now appends backtrace information to error log

BUG FIXES:

  * helpers/shell: fix carridge return handling
  * core/config: fix deepstruct unwrap issue

