desc 'Perform pull request operations'
namespace :pr do
  desc 'Create a new pull request'
  task :create do
    source_branch = Hem.ui.ask 'Source branch', default: (Hem::Helper.shell 'git rev-parse --abbrev-ref HEAD', :capture => true)
    target_branch = Hem.ui.ask 'Target branch', default: 'develop'

    pr_content = <<-prbody
# The line below this comment is the title of your pull request. Keep it short and on a single line.
PR_TITLE

# All text below this comment will appear as the body of the pull request.
# If your project has a DoD.md in the project root, it will be automatically included.
# Any line starting with a hash (comment) will be ignored

PR_DOD
prbody

    pr_content['PR_TITLE'] = Hem::Helper.shell 'git log -1 --pretty=%B', :capture => true

    dod_path = Hem::Helper.locate('DoD.md')

    if dod_path && !dod_path.empty?
      dod_file = File.open dod_path[0]
      pr_content['PR_DOD'] = dod_file.read
      dod_file.close
    else
      pr_content['PR_DOD'] = '# No DoD.md file found, add one to your project root.'
    end

    pr_body = Hem.ui.editor(pr_content).lines.reject{ |line| line[0] == '#' }.join

    pr_title = pr_body.lines.to_a[0]

    pr_body = pr_body.lines.to_a[1..-1].join

    git_parts = Hem::Helper.parse_github_url(Hem.project_config.git_url)
    repo = "#{git_parts[:owner]}/#{git_parts[:repo]}"

    api = Hem::Lib::Github::Api.new
    pr_url = api.create_pull_request(repo, target_branch, source_branch, pr_title, pr_body)

    Hem::ui.success "Pull request created: #{pr_url}"
  end
end
