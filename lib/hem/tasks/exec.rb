argument :command
argument 'args', optional: true, default: {}, as: Array
task 'exec' do |task, args|
  exec [args[:command], args[:command]], *args[:args]
end
