module Hem
  module Lib
    module Github
      class Api

        @connected = false

        def initialize(opts = {})
          @opts = {
            :config_class => Hem::Config::File,
            :user_config => Hem.user_config,
            :ui => Hem.ui,
            :client => Hem::Lib::Github::Client.new
          }.merge! opts
        end

        def connect
          config = @opts[:user_config]
          config[:github] ||= {}

          if config[:github][:token].nil?
            @opts[:ui].info 'You do not have a stored Github token. Authenticate now to create one.'
            username = @opts[:ui].ask 'Github username'
            password = @opts[:ui].ask 'Github password', echo: false

            config[:github][:token] = @opts[:client].get_token_for_credentials(username, password)

            @opts[:config_class].save(Hem.user_config_file, config)
          else
            @opts[:client].authenticate_with_token(config[:github][:token])
            # client = Octokit::Client.new(:access_token => config.github.token)
          end

          @connected = true
        end

        def create_pull_request(repo, source_branch, target_branch, title, body)
          unless @connected
            connect
          end

          @opts[:client].create_pull_request(repo, source_branch, target_branch, title, body)
        end

      end
    end
  end
end