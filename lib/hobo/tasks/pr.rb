desc 'Perform pull request operations'
namespace :pr do
  desc 'Create a new pull request'
  task :create do

    git_url = Hobo.project_config.git_url.split('/').reverse
    owner = git_url[1]
    repo_name = git_url[0].index('.git').nil? ? git_url[0] : git_url[0][0..-4]

    username = Hobo.ui.ask 'Github username'
    password = Hobo.ui.ask 'Github password', echo: false

    source_branch = Hobo.ui.ask 'Source branch', default: (Hobo::Helper.shell 'git rev-parse --abbrev-ref HEAD', :capture => true)
    target_branch = Hobo.ui.ask 'Target branch', default: 'develop'

    pr_content = <<-prbody
# The line below this comment is the title of your pull request. Keep it short and on a single line.
PR_TITLE

# All text below this comment will appear as the body of the pull request.
# If your project has a DoD.md in the project root, it will be automatically included.
# Any line starting with a hash (comment) will be ignored

PR_DOD
    prbody

    pr_content['PR_TITLE'] = Hobo::Helper.shell 'git log -1 --pretty=%B', :capture => true

    dod_path = Hobo::Helper.locate('DoD.md')

    if dod_path
      dod_file = File.open dod_path[0]
      pr_content['PR_DOD'] = dod_file.read
      dod_file.close
    else
      pr_content['PR_DOD'] = '# No DoD.md file found, add one to your project root.'
    end

    tmp = Tempfile.new('hobo_pr')
    begin
      tmp.write pr_content
      tmp.rewind
      tmp.close
      system('vi '+tmp.path)
      tmp.open
      pr_body = tmp.read
    rescue Exception => e
      Hobo::ui.error e.message
    ensure
      tmp.close
      tmp.unlink
    end

    pr_body_filtered = pr_body.lines.reject{ |line| line[0] == '#' }.join

    pr_title = pr_body_filtered.lines.to_a[0]

    client = Octokit::Client.new(:login => username, :password => password)

    response = client.create_pull_request "#{owner}/#{repo_name}", target_branch, source_branch, pr_title, pr_body_filtered.lines.to_a[1..-1].join

    Hobo::ui.success 'Pull request created: '+response[:html_url]
  end
end