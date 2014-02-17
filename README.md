# Hobo (gem)
Hobo is small rake based tool designed to assist with day to day tasks for developers.
Some highlights of functionality include:

- Fetch common tools
- Start most project VMs including setting up dependencies
- Utilize project seeds to kickstart a new project

Many more features are planned including assisting with host machine configuration, automatically pulling assets for the VM and providing commonly rewritten tasks as general utility libraries for use in Hobofiles.

# Pre-requisites
Hobo is a thin wrapper over our commonly used tools. As such, those tools still need to be present on your machine.
Hobo requires the following tools to be available on your path; if you can't execute these commands from a terminal you will need to install them before using hobo:

- git
- ruby
- rubygems
- bundler (rubygem)
- vagrant

# Installing
Simply execute the following command:
```
gem install hobo-inviqa
```

# Usage
Hobo is installed as a gem with a globally available binary called "hobo". Hobo allows you to get help for any command by specifying the --help option.
```
hobo --help
```

# Project specific commands
You can define project specific commands by creating a file in the root of the project called 'Hobofile'. Since hobo is based on Rake, you can use the normal Rake DSL to specify commands. Hobo also includes enhancements to this DSL that will be detailed later.

A task to download some specific files might look like:
```
desc "My-project tasks"
namespace "my-project" do
  desc "Download images"
  task "download-images" do
    Net::HTTP.get("my-domain.com", "/my-file.jpg")
  end
end
```

The above command would then be immediately available in hobo:
```
hobo my-project download-files
```

# Rake DSL enhancements
Please see https://github.com/inviqa/hobo-gem/wiki/Hobofile-DSL for comprehensive examples.

# Contributing
If you wish to contribute to hobo:
- Clone this repository
- Execute bundle install
- Create a feature branch with descriptive name (i.e. feature/magento-tasks)
- Make changes
- Build and install the gem: rake build && rake install
- Push feature branch back to this repo
- Submit a PR with details of changes

You can run tests using Guard by executing "guard" in a terminal in the project folder. Guard will re-run tests where it knows how but otherwise run cucumber tests with "cucumber" (in the guard terminal) and rspec tests with "rspec" (in the guard terminal).
