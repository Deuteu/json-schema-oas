RSpec.describe JSON::Oas::Version do
  describe '::DEFAULT_VERSION' do
    it 'is defined' do
      expect(defined?(JSON::Oas::Version::DEFAULT_VERSION)).to be_truthy
    end

    it 'is a string' do
      expect(JSON::Oas::Version::DEFAULT_VERSION).to be_kind_of(String)
    end
  end

  describe '::VERSIONS' do
    it 'is defined' do
      expect(defined?(JSON::Oas::Version::VERSIONS)).to be_truthy
    end

    it 'is an array' do
      expect(JSON::Oas::Version::VERSIONS).to be_kind_of(Array)
    end

    it 'is contains the default version' do
      expect(JSON::Oas::Version::VERSIONS).
        to include(JSON::Oas::Version::DEFAULT_VERSION)
    end
  end
end
