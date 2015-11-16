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
function __hem_completion -d "Create hem completions"
  set -l cache_dir "/tmp/fish_hem_completion_cache"
  mkdir -p $cache_dir
  set -l hashed_pwd (ruby -r 'digest' -e 'puts Digest::MD5.hexdigest(`pwd`)')
  set -l hem_cache_file "$cache_dir/$hashed_pwd"

  if not test -f "$hem_cache_file"
    hem system completions fish --skip-host-checks > "$hem_cache_file"
  end

  cat "$hem_cache_file"
end

function __hem_scope_test -d "Hem scoped completion test"
  set cmd (commandline -opc)
  if [ "$cmd" = "$argv" ]
    return 0
  end
  return 1
end

eval (__hem_completion)
EOF
        target = File.join(ENV['HOME'], '.config/fish/completions/hem.fish')
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
      Hem.cli.slop.options.each do |option|
        short = option.short.nil? ? '' : "-s #{option.short}"
        long = option.long.nil? ? '' : "-l #{option.long}"
        arg = option.config[:argument] ? '' : '-x'
        puts "complete #{arg} -c hem #{short} #{long} --description '#{option.description}';"
      end

      map = Hem.cli.help_formatter.command_map
      map.each do |k, v|
        next if v.description.nil? || v.description.empty?
        k = k.split(':')
        k.unshift 'hem'
        c = k.pop
        puts "complete -x -c hem -n '__hem_scope_test #{k.join(' ')}' -a #{c} --description '#{v.description}';"
        v.options.each do |option|
          short = option.short.nil? ? '' : "-s #{option.short}"
          long = option.long.nil? ? '' : "-l #{option.long}"
          arg = option.config[:argument] ? '' : '-x'
          puts "complete #{arg} -c hem -n '__hem_scope_test #{k.concat([c]).join(' ')}' #{short} #{long} --description '#{option.description}';"
        end
      end
    end
  end
end
