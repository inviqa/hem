module Hobo
  module Helper
    def parse_github_url(url)
      matches = /github\.com[\/:]+(?<owner>.*)\/(?<repo>((?!\.git).)*)/.match(url)
      {:owner => matches[:owner], :repo => matches[:repo]}
    end
  end
end

include Hobo::Helper
