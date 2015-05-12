
describe Hem::Lib::Github::Api do

  default_config = {}
  token = 'abcdabcdabcdabcdabcdabcdabcdabcdabcdabcd'

  before do
    default_config = {
      :ui => double(Hem::Ui).as_null_object,
      :user_config => {},
      :client => double(Hem::Lib::Github::Client).as_null_object,
      :config_class => double(Hem::Config::File).as_null_object
    }
  end

  describe 'connect' do

    it 'should request credentials if a token is not saved' do
      expect(default_config[:ui]).to receive(:info).with(kind_of(String))
      expect(default_config[:ui]).to receive(:ask).with('Github username')
      expect(default_config[:ui]).to receive(:ask).with('Github password', echo: false)

      api = Hem::Lib::Github::Api.new(default_config)
      api.connect
    end

    it 'should use the credentials to request a token' do
      allow(default_config[:ui]).to receive(:ask).and_return('username', 'password')
      expect(default_config[:client]).to receive(:get_token_for_credentials).with('username', 'password')

      api = Hem::Lib::Github::Api.new(default_config)
      api.connect
    end

    it 'should save a new token to user config' do
      allow(default_config[:client]).to receive(:get_token_for_credentials).and_return(token)
      expect(default_config[:config_class]).to receive(:save).with(Hem.user_config_file, {
        :github => {
          :token => token
        }
      })

      api = Hem::Lib::Github::Api.new(default_config)
      api.connect
    end

    it 'should use a stored token if one is found' do
      default_config[:user_config] = {
        :github => {
          :token => token
        }
      }

      expect(default_config[:client]).to receive(:authenticate_with_token).with(token)

      api = Hem::Lib::Github::Api.new(default_config)
      api.connect
    end

  end

  describe 'create_pull_request' do

    it 'should create a pull request if connected' do
      default_config[:user_config] = {
        :github => {
          :token => token
        }
      }

      expect(default_config[:client]).to receive(:create_pull_request).with('repo', 'source', 'target', 'title', 'body')

      api = Hem::Lib::Github::Api.new(default_config)
      api.create_pull_request('repo', 'source', 'target', 'title', 'body')
    end

    it 'should return the url to the pull request' do
      default_config[:user_config] = {
        :github => {
          :token => token
        }
      }

      allow(default_config[:client]).to receive(:create_pull_request).and_return('url')

      api = Hem::Lib::Github::Api.new(default_config)
      expect(api.create_pull_request('repo', 'source', 'target', 'title', 'body')).to eq('url')
    end

  end

end
