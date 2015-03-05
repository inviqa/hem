desc "Internal hobo debugging tools"
hidden true
namespace 'self'  do

  desc "REPL"
  task :repl do
    require 'pry'
    Pry.config.prompt = if STDIN.tty?
      proc { 'hobo > '}
    else
      proc { '' }
    end
    pry
  end

  desc "Tasks for debugging hobo"
  namespace 'debug' do
    desc "Display project paths"
    project_only
    task "paths" do
      Hobo.ui.info "<%=color('Project path:', :green)%> " + Hobo.project_path
      {
        :gemfile => "*Gemfile",
        :vagrantfile => "*Vagrantfile",
        :cheffile => "*Cheffile",
        :berksfile => "*Berksfile",
        :'composer.json' => "composer.json"
      }.each do |k,v|
        path = nil
        locate v do |file, full_file|
          path = full_file
        end
        Hobo.ui.info "<%=color('#{k.to_s}:', :green) %> #{path.nil? ? "none" : path}"
      end
    end

    desc "Locate"
    project_only
    task "locate", [ :arg ] do |task, args|
      locate args[:arg] do |file, full_file|
        puts full_file
      end
    end
  end
end
