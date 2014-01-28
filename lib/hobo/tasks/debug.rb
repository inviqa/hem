desc "Internal hobo debugging tools"
hidden true
namespace 'hobo-debug'  do

  desc "Display project paths"
  project_only
  task "paths" do
    Hobo.ui.info "<%=color('Project path:', :green)%> " + Hobo.project_path
    {
      :gemfile => "*Gemfile",
      :vagrantfile => "*Vagrantfile",
      :cheffile => "*Cheffile",
      :'composer.json' => "composer.json"
    }.each do |k,v|
      path = nil
      locate v do |p|
        path = p
      end
      Hobo.ui.info "<%=color('#{k.to_s}:', :green) %> #{path.nil? ? "none" : path}"
    end
  end
end