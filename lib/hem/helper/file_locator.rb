module Hem
  module Helper
    def locate(pattern, opts = {}, &block)
      match = nil

      Dir.chdir Hem.project_path do
        match = locate_git(pattern, &block)
      end

      return match unless block_given?
      return true if match

      Hem.ui.warning opts[:missing] if opts[:missing]
      return false
    end

    private

    def locate_git pattern, &block
      args = [ 'git', 'ls-files', pattern ]
      output = Hem::Helper.shell *args, :capture => true
      paths = output.split("\n")
      found = false
      paths.each do |path|
        path.strip!
      end

      return paths unless block_given?

      paths.each do |path|
        Dir.chdir File.dirname(path) do
          Hem::Logging.logger.debug "helper.locator: Found #{path} for #{pattern}"
          yield File.basename(path), path
        end

        found = true
      end

      return found
    end
  end
end

include Hem::Helper
