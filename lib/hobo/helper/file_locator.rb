module Hobo
  module Helper
    def locate(pattern, opts = {}, &block)
      match = nil

      Dir.chdir Hobo.project_path do
        match = locate_git(pattern, false, &block)
        match = locate_git(pattern, true, &block) if !match
      end

      return true if match

      Hobo.ui.warning opts[:missing] if opts[:missing]
      return false
    end

    private

    def locate_git pattern, others, &block
      args = [ 'git', 'ls-files', pattern ]
      args.push '-o' if others
      output = Hobo::Helper.shell *args, :capture => true
      paths = output.split("\n")
      found = false
      paths.each do |path|
        path.strip!
        Dir.chdir File.dirname(path) do
          Hobo::Logging.logger.debug "helper.locator: Found #{path} for #{pattern}"
          yield File.basename(path), path
        end

        found = true
      end

      return found
    end
  end
end

include Hobo::Helper