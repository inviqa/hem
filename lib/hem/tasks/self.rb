desc "Internal hem debugging tools"
hidden true
namespace 'self'  do

  desc "REPL"
  task :repl do
    require 'pry'
    Pry.config.prompt = if STDIN.tty?
      proc { 'hem > '}
    else
      proc { '' }
    end
    pry
  end

  desc "Tasks for debugging hem"
  namespace 'debug' do
    desc "Display project paths"
    project_only
    task "paths" do
      Hem.ui.info "<%=color('Project path:', :green)%> " + Hem.project_path
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
        Hem.ui.info "<%=color('#{k.to_s}:', :green) %> #{path.nil? ? "none" : path}"
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
