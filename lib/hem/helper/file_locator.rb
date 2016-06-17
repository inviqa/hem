module Hem
  module Helper
    extend self

    def locate(name, patterns = nil, opts = {}, &block)
      opts = {
        type: 'git',
        patterns: patterns || [name, "**/#{name}"],
        path: Hem.project_path,
      }.merge(opts)

      match = nil

      unless Hem.project_config[:locate].nil? || Hem.project_config[:locate][name].nil?
        opts = opts.merge(Hem.project_config[:locate][name].to_hash_sym)
      end

      Dir.chdir opts[:path] do
        case opts[:type]
        when 'git'
          match = locate_git(opts[:patterns], &block)
        when 'files'
          match = locate_files(opts[:patterns], &block)
        end
      end

      return match unless block_given?
      return true if match

      Hem.ui.warning opts[:missing] if opts[:missing]
      return false
    end

    private

    def locate_files patterns, &block
      paths = patterns.inject([]) do |result, pattern|
        result + Dir.glob(pattern)
      end
      locate_loop paths, &block
    end

    def locate_git patterns, &block
      args = [ 'git', 'ls-files', *patterns ]
      output = Hem::Helper.shell *args, :capture => true
      paths = output.split("\n")
      paths.each do |path|
        path.strip!
      end
      locate_loop paths, &block
    end

    def locate_loop paths, &block
      return paths unless block_given?

      found = false
      paths.each do |path|
        Dir.chdir File.dirname(path) do
          Hem::Logging.logger.debug "helper.locator: Found #{path}"
          yield File.basename(path), path
        end

        found = true
      end

      return found
    end
  end
end

self.extend Hem::Helper
