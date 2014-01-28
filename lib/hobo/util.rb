module Hobo
  class << self
    def in_project?
      !Hobo.project_path.nil?
    end
  end
end