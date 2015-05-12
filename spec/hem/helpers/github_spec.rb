
describe Hobo::Helper do
  describe 'parse_github_url' do

    it 'should return the parts of a git protocol url' do
      url = 'git://github.com/foo/bar'
      expect(parse_github_url(url)).to eq({:owner => 'foo', :repo => 'bar'})
    end

    it 'should return the parts of an https url' do
      url = 'https://github.com/foo/bar'
      expect(parse_github_url(url)).to eq({:owner => 'foo', :repo => 'bar'})
    end

    it 'should return the parts of a git ssh url' do
      url = 'git@github.com:foo/bar'
      expect(parse_github_url(url)).to eq({:owner => 'foo', :repo => 'bar'})
    end

    it 'should trim the .git https url ending if present' do
      url = 'https://github.com/foo/bar.git'
      expect(parse_github_url(url)).to eq({:owner => 'foo', :repo => 'bar'})
    end

    it 'should trim the .git ssh url ending if present' do
      url = 'git@github.com:foo/bar.git'
      expect(parse_github_url(url)).to eq({:owner => 'foo', :repo => 'bar'})
    end

  end
end
