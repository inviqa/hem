desc "System configuration related commands"
namespace :system do

  desc "Check system configuration for potential problems"
  task :check do
    Hobo::Lib::HostCheck.check.each do |k,v|
      name = k.to_s.gsub('_', ' ')
      name[0] = name[0].upcase

      if v == :ok
        Hobo.ui.success "#{name}: OK"
      else
        Hobo.ui.error "#{name}: FAILED\n"
        Hobo.ui.warning v.advice.gsub(/^/, '  ')
      end
    end
  end
end
