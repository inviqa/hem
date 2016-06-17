module Hem
  module Helper
    def parse_github_url(url)
      matches = /github\.com[\/:]+(?<owner>.*)\/(?<repo>((?!\.git).)*)/.match(url)
      {:owner => matches[:owner], :repo => matches[:repo]}
    end
  end
end

self.extend Hem::Helper
