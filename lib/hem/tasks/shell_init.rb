namespace 'shell-init' do
  def posix_export_path
    Hem.ui.output %Q(export PATH="#{ENV['PATH']}")
  end

  def fish_export_path
    Hem.ui.output %Q(set -gx PATH "#{ENV['PATH'].split(':').join('" "')}" 2>/dev/null;)
  end

  task 'bash' do
    posix_export_path
  end

  task 'sh' do
    posix_export_path
  end

  task 'zsh' do
    posix_export_path
  end

  task 'fish' do
    fish_export_path
  end
end
