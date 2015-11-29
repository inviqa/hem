module Hem
  module Lib
    module Github
      class Client

       @client = nil

        def initialize(opts = {})
          require 'octokit'
          @opts = {
            :client_class => Octokit::Client
          }.merge! opts
        end

        def get_token_for_credentials(username, password)
          begin
            @client = @opts[:client_class].new(:login => username, :password => password)
            token_response = @client.create_authorization(:scopes => ['repo'], :note => 'Hem')
            return token_response.token.to_s
          rescue Octokit::UnprocessableEntity => e
            case e.errors[0][:code]
              when 'already_exists'
                raise Hem::GithubAuthenticationError.new 'You already created a token for Hem, please delete this from your Github account before continuing.'
              else
                raise Hem::Error.new e.message
            end
          rescue Exception => e
            raise Hem::Error.new e.message
          end
        end

        def authenticate_with_token(token)
          begin
            @client = @opts[:client_class].new(:access_token => token)
          rescue Exception => e
            raise Hem::Error.new e.message
          end
        end

        def create_pull_request(repo, source_branch, target_branch, title, body)
          if @client.nil?
            raise Hem::Error.new 'Client is not created'
          end

          response = @client.create_pull_request(repo, source_branch, target_branch, title, body)
          response[:html_url].to_s
        end

      end
    end
  end
end
