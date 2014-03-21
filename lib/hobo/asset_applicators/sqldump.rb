Hobo.asset_applicators.register /.*\.sql\.gz/ do |file|
  matches = file.match(/^([^\.]+).*\.sql\.gz/)
  db = File.basename(matches[1])

  begin
    shell(vm_mysql(:mysql => 'mysqladmin', :append => " create #{db.shellescape}"))
  rescue Hobo::ExternalCommandError => e
    Hobo.ui.warning "Already applied (#{file})"
    raise e if e.exit_code != 1
    next
  end

  Hobo.ui.title "Applying mysqldump (#{file})"
  shell(vm_mysql(:auto_echo => false, :db => db) < "zcat #{file.shellescape}")
end