module Hem
  class << self
    attr_accessor :plugins
  end

  class Plugins

    def initialize(path, gemfile, lockfile = nil)
      @is_setup = false
      @gemfile = gemfile
      if lockfile.nil?
        @lockfile = "#{gemfile}.lock"
      else
        @lockfile = lockfile
      end

      @old_root = Bundler.method(:root)
      def Bundler.root(path = nil)
        @root = Pathname.new(path) if path
        @root
      end

      Bundler.root path
      @builder = Class.new(Bundler::Dsl) do
        define_method(:gemfile_root) do
          Bundler.root
        end
      end.new
      @definition = nil
    end

    def setup
      raise Hem::PluginsAlreadySetupError if @is_setup
      @is_setup = true
      install unless check
      require
    end

    def setup?
      @is_setup
    end

    def define(&block)
      raise Hem::PluginsAlreadySetupError if @is_setup
      @builder.instance_eval &block

      self
    end

    def check
      return false unless File.exist?(File.join(Bundler.root, @lockfile))
      begin
        missing_specs = definition.missing_specs.any?
      rescue Bundler::GemNotFound, Bundler::VersionConflict, Bundler::GitError
        missing_specs = true
      end
      # clear the definition after the check, so install/upgrade re-evaluates
      @definition = nil
      return !missing_specs
    end

    def install(options = {})
      return self if definition.dependencies.empty?

      opts = options.dup
      opts[:system] = true
      ui = opts.delete(:ui) { Bundler::UI::Shell.new }

      Bundler.ui = ui
      begin
        ENV["BUNDLE_GEMFILE"] = File.join(Bundler.root, @gemfile)
        Bundler::Installer.install(Bundler.root, definition, opts)
        ENV.delete("BUNDLE_GEMFILE")
        Bundler::Installer.post_install_messages.each do |name, message|
          Hem.ui.info "Post-install message from #{name}:\n#{message}"
        end
      rescue Bundler::GemNotFound => e
        raise e, e.message.sub('Gemfile', 'Hemfile'), e.backtrace
      rescue Bundler::GitError => e
        raise e, e.message.sub('bundle install', 'hem plugin install'), e.backtrace
      end

      self
    end

    def update(unlock = true, options = {})
      opts = options.dup
      opts['update'] = true
      definition(unlock)
      install(opts)
    end

    def require
      runtime = Bundler::Runtime.new(nil, definition)
      def runtime.clean_load_path(*); end
      def runtime.setup_environment(*); end;
      def runtime.lock(*); end;

      runtime.setup
      definition.lock(File.join(Bundler.root, @lockfile), :preserve_bundled_with => true) unless @lockfile === false

      runtime.require

      self
    end

    private

    def definition(unlock = nil)
      @definition = nil if unlock
      return @definition unless @definition.nil?

      unlock = {} if unlock.nil?
      @definition = @builder.to_definition(@lockfile, unlock)
      @definition.validate_ruby!

      @definition
    end
  end
end
