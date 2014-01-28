require 'open3'

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
      path = output.split("\n")[0]

      unless path.nil?
        path.strip!
        Dir.chdir File.dirname(path) do
          yield path
        end

        return true
      end
    end
  end
end

include Hobo::Helper