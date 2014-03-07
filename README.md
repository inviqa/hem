# Hobo (gem)
Hobo is small rake based tool designed to assist with day to day tasks for developers.
Some highlights of functionality include:

- Fetch common tools
- Start most project VMs including setting up dependencies
- Utilize project seeds to kickstart a new project

Many more features are planned including assisting with host machine configuration, automatically pulling assets for the VM and providing commonly rewritten tasks as general utility libraries for use in Hobofiles.

# Installing & using

Full instructions for installing and using hobo are available in the [User guide](https://github.com/inviqa/hobo-gem/wiki/User-guide). For information on the task DSL, see the  [DSL guide](https://github.com/inviqa/hobo-gem/wiki/Hobofile-DSL).

If you have a working development configuration (and are using OSX / linux), you may skip reading those instructions and go straight to installing the gem:

```
gem install hobo-inviqa
```

Please ensure that you run the following command after installing and that it does not raise any issues:

```
hobo system check
```

# Getting help

If you need any help with hobo or you encounter any issues, please join the #hobo slack channel.

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
