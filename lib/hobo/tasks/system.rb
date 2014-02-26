desc "System configuration related commands"
namespace :system do

  desc "Check system configuration for potential problems"
  task :check do
    Hobo::Lib::HostCheck.check.each do |k,v|
      if v == :ok
        Hobo.ui.success "#{k}: OK"
      else
        Hobo.ui.error "#{k}: FAILED\n"
        Hobo.ui.warning v.advice.gsub(/^/, '  ')
      end
    end
  end
end
