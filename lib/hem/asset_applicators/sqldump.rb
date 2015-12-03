# Built in applicators
Hem.asset_applicators.register 'sqldump', /.*\.sql\.gz/ do |file, opts|
  matches = file.match(/^([^\.]+).*\.sql\.gz/)
  db = File.basename(matches[1])

  status = {
    :db_exists => false,
    :db_has_tables => false
  }

  begin
    result = shell(create_mysql_command(:db => db).pipe('SHOW TABLES; SELECT FOUND_ROWS();', :on => :vm), :capture => true)
    status[:db_exists] = true
    status[:db_has_tables] = !(result.split("\n").last.strip == '0')
  rescue Hem::ExternalCommandError
    # This will fail later with a more useful error message
  end

  if status[:db_exists] && status[:db_has_tables] && !opts[:force]
      Hem.ui.warning "Already applied (#{file})"
    next
  end

  if status[:db_exists] && (!status[:db_has_tables] || opts[:force])
    # Db exists but is empty, or is being reapplied
    shell(create_mysql_command(:mysql => 'mysqladmin', :append => " --force drop #{db.shellescape}"))
  end

  begin
    Hem.ui.title "Applying mysqldump (#{file})"
    shell(create_mysql_command(:mysql => 'mysqladmin', :append => " create #{db.shellescape}"))
    shell(create_mysql_command(:auto_echo => false, :db => db) < "zcat #{file.shellescape}")
  rescue Hem::ExternalCommandError => exception
    Hem.ui.error "Could not apply #{file} due to the following error:\n"
    Hem.ui.error File.read(exception.output.path).strip
    raise exception
  end
end
