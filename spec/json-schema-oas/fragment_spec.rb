RSpec.describe JSON::Oas::Fragment do
  Fragment = JSON::Oas::Fragment
  Error = JSON::Oas::Error

  describe '.response_schema_for' do
    context 'with an unknown version' do
      it 'raises an unknown version Error' do
        expect { Fragment.response_schema_for('0.0', '') }.
          to raise_error(Error, Error::UNKNOWN_VERSION_ERROR)
      end
    end

    context 'with OAS 2.0 version' do
      context 'when method and code are not given' do
        it 'raises an ArgumentError' do
          expect { Fragment.response_schema_for(JSON::Oas::Version::OAS2, 'Object') }.
            to raise_error(ArgumentError)
          expect { Fragment.response_schema_for(JSON::Oas::Version::OAS2, 'Object', nil) }.
            to raise_error(ArgumentError)
          expect { Fragment.response_schema_for(JSON::Oas::Version::OAS2, 'Object', :get) }.
            to raise_error(ArgumentError)
          expect { Fragment.response_schema_for(JSON::Oas::Version::OAS2, 'Object', :get, nil) }.
            to raise_error(ArgumentError)
          expect { Fragment.response_schema_for(JSON::Oas::Version::OAS2, 'Object', nil, 200) }.
            to raise_error(ArgumentError)
        end
      end

      context 'when all arguments are given' do
        let(:fragment) { Fragment.response_schema_for(JSON::Oas::Version::OAS2, '/path', :get, 200) }

        it 'returns a Fragment' do
          expect(fragment).to be_a(Fragment)
        end

        it 'returns the keys routing to the given schema' do
          expect(fragment).to eq(%w[# paths /path get responses 200 schema])
        end
      end
    end

    context 'with OAS 3.0 version' do
      let(:fragment) { Fragment.response_schema_for(JSON::Oas::Version::OAS3, 'Object', :get, 200) }

      it 'calls .v3_response_schema_for' do
        allow(Fragment).to receive(:v3_response_schema_for)

        fragment

        expect(Fragment).to have_received(:v3_response_schema_for).with('Object', :get, 200)
      end
    end
  end

  describe '.schema_for' do
    context 'with an unknown version' do
      it 'raises an unknown version Error' do
        expect { Fragment.schema_for('0.0', '') }.
          to raise_error(Error, Error::UNKNOWN_VERSION_ERROR)
      end
    end

    context 'with OAS 2.0 version' do
      let(:fragment) { Fragment.schema_for(JSON::Oas::Version::OAS2, 'Object') }

      it 'returns a Fragment' do
        expect(fragment).to be_a(Fragment)
      end

      it 'returns the keys routing to the given schema' do
        expect(fragment).to eq(%w[# definitions Object])
      end
    end

    context 'with OAS 3.0 version' do
      let(:fragment) { Fragment.schema_for(JSON::Oas::Version::OAS3, 'Object') }

      it 'returns a Fragment' do
        expect(fragment).to be_a(Fragment)
      end

      it 'returns the keys routing to the given schema' do
        expect(fragment).to eq(%w[# components schemas Object])
      end
    end
  end

  describe '.v3_response_schema_for' do
    context 'when name is not given' do
      it 'raises an ArgumentError' do
        expect { Fragment.send(:v3_paths_response_schema_for, nil, nil, nil) }.
          to raise_error(ArgumentError)
        expect { Fragment.send(:v3_paths_response_schema_for, nil, nil, 200) }.
          to raise_error(ArgumentError)
        expect { Fragment.send(:v3_paths_response_schema_for, nil, :get, nil) }.
          to raise_error(ArgumentError)
      end
    end

    context 'when name is given' do
      context 'when method is not given' do
        let(:fragment) { Fragment.send(:v3_response_schema_for, 'Object', nil, 200) }

        it 'returns a Fragment' do
          expect(fragment).to be_a(Fragment)
        end

        it 'returns the fragment for a components responses' do
          expect(fragment).to include('components')
        end

        it 'returns the keys routing to the given schema' do
          expect(fragment).to eq(%w[# components responses Object content application/json schema])
        end
      end

      context 'when code is not given' do
        let(:fragment) { Fragment.send(:v3_response_schema_for, 'Object', :get, nil) }

        it 'returns a Fragment' do
          expect(fragment).to be_a(Fragment)
        end

        it 'returns the fragment for a components responses' do
          expect(fragment).to include('components')
        end

        it 'returns the keys routing to the given schema' do
          expect(fragment).to eq(%w[# components responses Object content application/json schema])
        end
      end

      context 'when all arguments are given' do
        let(:fragment) { Fragment.send(:v3_response_schema_for, '/path', :get, 200) }

        it 'returns a Fragment' do
          expect(fragment).to be_a(Fragment)
        end

        it 'returns the fragment for a paths responses' do
          expect(fragment).to include('paths')
        end

        it 'returns correct keys routing' do
          expect(fragment).to eq(%w[# paths /path get responses 200 content application/json schema])
        end
      end
    end
  end

  describe '.v3_paths_response_schema_for' do
    context 'when path is not given' do
      it 'raises an ArgumentError' do
        expect { Fragment.send(:v3_paths_response_schema_for, nil, :get, 200) }.
          to raise_error(ArgumentError)
      end
    end

    context 'when method is not given' do
      it 'raises an ArgumentError' do
        expect { Fragment.send(:v3_paths_response_schema_for, '/path', nil, 200) }.
          to raise_error(ArgumentError)
      end
    end

    context 'when code is not given' do
      it 'raises an ArgumentError' do
        expect { Fragment.send(:v3_paths_response_schema_for, '/path', :get, nil) }.
          to raise_error(ArgumentError)
      end
    end

    context 'when all argument are given' do
      let(:fragment) { Fragment.send(:v3_paths_response_schema_for, '/path', :get, 200) }

      it 'returns a Fragment' do
        expect(fragment).to be_a(Fragment)
      end

      it 'returns correct keys routing' do
        expect(fragment).to eq(%w[# paths /path get responses 200 content application/json schema])
      end
    end
  end

  describe '#split' do
    let(:fragment) { Fragment.new([1, 2, 3]) }

    it 'returns an Array' do
      expect(fragment.split).to be_a(Array)
    end

    it 'returns a different object' do
      expect { fragment.split.shift }.
        not_to(change { fragment.length })
    end
  end
end
