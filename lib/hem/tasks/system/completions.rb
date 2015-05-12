desc "System configuration related commands"
namespace :system do

  desc "Shell completion related commands"
  namespace :completions do

    desc "Install shell completion helpers"
    option '-f', '--fish', 'Install completions for FISH'
    option '-b', '--bash', 'Install completions for Bash'
    option '-z', '--zsh', 'Install completions for ZSH'
    task "install" do |task|
      if task.opts[:fish]
        script = <<-EOF
function __hobo_completion -d "Create hobo completions"
  set -l cache_dir "/tmp/fish_hobo_completion_cache"
  mkdir -p $cache_dir
  set -l hashed_pwd (ruby -r 'digest' -e 'puts Digest::MD5.hexdigest(`pwd`)')
  set -l hobo_cache_file "$cache_dir/$hashed_pwd"

  if not test -f "$hobo_cache_file"
    hobo system completions fish --skip-host-checks > "$hobo_cache_file"
  end

  cat "$hobo_cache_file"
end

function __hobo_scope_test -d "Hobo scoped completion test"
  set cmd (commandline -opc)
  if [ "$cmd" = "$argv" ]
    return 0
  end
  return 1
end

eval (__hobo_completion)
EOF
        target = File.join(ENV['HOME'], '.config/fish/completions/hobo.fish')
        FileUtils.mkdir_p(File.dirname(target))
        File.write(target, script)
      end

      if task.opts[:bash]
        raise "Bash completions not yet implemented"
      end

      if task.opts[:zsh]
        raise "ZSH completions not yet implemented"
      end
    end

    desc "Display FISH shell completion commands"
    task :fish do
      Hobo.cli.slop.options.each do |option|
        short = option.short.nil? ? '' : "-s #{option.short}"
        long = option.long.nil? ? '' : "-l #{option.long}"
        arg = option.config[:argument] ? '' : '-x'
        puts "complete #{arg} -c hobo #{short} #{long} --description '#{option.description}';"
      end

      map = Hobo.cli.help_formatter.command_map
      map.each do |k, v|
        next if v.description.nil? || v.description.empty?
        k = k.split(':')
        k.unshift 'hobo'
        c = k.pop
        puts "complete -x -c hobo -n '__hobo_scope_test #{k.join(' ')}' -a #{c} --description '#{v.description}';"
        v.options.each do |option|
          short = option.short.nil? ? '' : "-s #{option.short}"
          long = option.long.nil? ? '' : "-l #{option.long}"
          arg = option.config[:argument] ? '' : '-x'
          puts "complete #{arg} -c hobo -n '__hobo_scope_test #{k.concat([c]).join(' ')}' #{short} #{long} --description '#{option.description}';"
        end
      end
    end
  end
end
