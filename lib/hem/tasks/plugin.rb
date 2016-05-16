namespace :plugin do
  desc "Install a project's defined Hemfile plugins"
  task :install do
    Hem.plugins.install
  end

  desc "Update a project's defined Hemfile plugins"
  argument 'gems', optional: true, default: {}, as: Array
  task :update do |t, args|
    if args[:gems].empty?
      Hem.plugins.update
    else
      Hem.plugins.update gems: args[:gems]
    end
  end
end
