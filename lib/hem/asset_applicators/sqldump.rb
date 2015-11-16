# Built in applicators
Hem.asset_applicators.register /.*\.sql\.gz/ do |file|
  matches = file.match(/^([^\.]+).*\.sql\.gz/)
  db = File.basename(matches[1])

  status = {
    :db_exists => false,
    :db_has_tables => false
  }

  begin
    result = shell(vm_mysql(:db => db).pipe('SHOW TABLES; SELECT FOUND_ROWS();', :on => :vm), :capture => true)
    status[:db_exists] = true
    status[:db_has_tables] = !(result.split("\n").last.strip == '0')
  rescue Hem::ExternalCommandError
    # This will fail later with a more useful error message
  end

  if status[:db_exists] && status[:db_has_tables]
    Hem.ui.warning "Already applied (#{file})"
    next
  end

  if status[:db_exists] && !status[:db_has_tables]
    # Db exists but is empty
    shell(vm_mysql(:mysql => 'mysqladmin', :append => " --force drop #{db.shellescape}"))
  end

  begin
    Hem.ui.title "Applying mysqldump (#{file})"
    shell(vm_mysql(:mysql => 'mysqladmin', :append => " create #{db.shellescape}"))
    shell(vm_mysql(:auto_echo => false, :db => db) < "zcat #{file.shellescape}")
  rescue Hem::ExternalCommandError => exception
    Hem.ui.error "Could not apply #{file} due to the following error:\n"
    Hem.ui.error File.read(exception.output.path).strip
    raise exception
  end
end
