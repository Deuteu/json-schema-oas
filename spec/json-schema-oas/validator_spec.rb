RSpec.describe JSON::Oas::Validator do
  Validator = JSON::Oas::Validator
  Error = JSON::Oas::Error
  Version = JSON::Oas::Version

  oas2_schema_path = File.expand_path('../../data/schema/petstore.oas2.yml', __dir__)
  oas3_schema_path = File.expand_path('../../data/schema/petstore.oas3.yml', __dir__)

  example_oas2_schema = YAML.safe_load(File.read(oas2_schema_path))
  example_oas3_schema = YAML.safe_load(File.read(oas3_schema_path))
  invalid_oas2_schema = YAML.safe_load(File.read(File.expand_path('../../data/schema/invalid/petstore.oas2.yml', __dir__)))
  invalid_oas3_schema = YAML.safe_load(File.read(File.expand_path('../../data/schema/invalid/petstore.oas3.yml', __dir__)))

  data_examples_folder = File.expand_path('../../data/example', __dir__)

  describe '.valid_schema?' do
    context 'with an unknown version' do
      it 'raises an Error' do
        expect { Validator.valid_schema?({}, '0') }.to raise_error(JSON::Oas::Error)
      end
    end

    context 'with an OAS 3.0 version' do
      let(:version) { JSON::Oas::Version::OAS3 }

      context 'with an invalid schema' do
        it 'returns false' do
          expect(Validator.valid_schema?(invalid_oas3_schema, version)).to eq(false)
          expect(Validator.valid_schema?(example_oas2_schema, version)).to eq(false)
        end
      end

      context 'with an valid schema' do
        it 'returns true' do
          expect(Validator.valid_schema?(example_oas3_schema, version)).to eq(true)
        end
      end
    end

    context 'with an OAS 2.0 version' do
      let(:version) { JSON::Oas::Version::OAS2 }

      context 'with an invalid schema' do
        it 'returns false' do
          expect(Validator.valid_schema?(invalid_oas2_schema, version)).to eq(false)
          expect(Validator.valid_schema?(example_oas3_schema, version)).to eq(false)
        end
      end

      context 'with an valid schema' do
        it 'returns true' do
          expect(Validator.valid_schema?(example_oas2_schema, version)).to eq(true)
        end
      end
    end
  end

  describe '.new' do
    context 'with an unknown version' do
      it 'raises an Error' do
        expect { Validator.new({}, {}, oas_version: '0') }.
          to raise_error(Error, Error::UNKNOWN_VERSION_ERROR)
      end
    end

    context 'with no version' do
      it 'fallbacks to the default version' do
        expect(Validator.new(example_oas3_schema, {}).instance_variable_get(:@oas_version)).
          to eq(Version::DEFAULT_VERSION)
      end
    end

    context 'with a valid version' do
      it 'computes the fragment option' do
        allow(Validator).to receive(:compute_fragment).and_call_original

        Validator.new(example_oas3_schema, {})

        expect(Validator).to have_received(:compute_fragment).once
      end

      it 'validates the schema' do
        allow(Validator).to receive(:valid_schema?).and_call_original

        Validator.new(example_oas3_schema, {})

        expect(Validator).to have_received(:valid_schema?).once
      end

      context 'when schema is invalid' do
        it 'raises an invalid schema Error' do
          expect { Validator.new({}, {}) }.
            to raise_error(Error, Error::INVALID_SCHEMA_ERROR)
        end
      end
    end
  end

  describe '.compute_fragment' do
    context 'when fragment option is given' do
      it 'returns the same options' do
        options = {fragment: 'some/fragment'}
        expect(Validator.compute_fragment('', options)).to eq(options)
      end
    end

    context 'when no fragment option is given' do
      let(:version) { Version::OAS3 }

      context 'when with_schema option is given' do
        let(:schema) { 'Pet' }

        it 'the same hash with the fragment of the given schema' do
          options = {key: 'value', with_schema: schema}
          computed_options = Validator.compute_fragment(version, options)

          expect(computed_options).to include(options)
          expect(computed_options).to have_key(:fragment)
          expect(computed_options[:fragment]).to eq(Fragment.schema_for(version, schema))
        end
      end

      context 'when with_schema option is not given' do
        context 'when with_response option is given' do
          let(:response) { ['/pets', :get, 200] }

          it 'the same hash with the fragment of the given schema' do
            options = {key: 'value', with_response: response}
            computed_options = Validator.compute_fragment(version, options)

            expect(computed_options).to include(options)
            expect(computed_options).to have_key(:fragment)
            expect(computed_options[:fragment]).to eq(Fragment.response_schema_for(version, *response))
          end
        end
      end
    end
  end

  describe '#initialize_schema' do
    context 'with invalid data' do
      it 'raises an JSON::Schema::SchemaParseError' do
        expect { Validator.new(example_oas3_schema, {}).send(:initialize_schema, []) }.
          to raise_error(JSON::Schema::SchemaParseError)
      end
    end

    context 'with valid data' do
      it 'returns a JSON::Schema' do
        schema = Validator.new(example_oas3_schema, {}).send(:initialize_schema, {})
        expect(schema).to be_a(JSON::Schema)
      end

      it 'assigns a duplicate of the returned value to @original_schema variable' do
        validator = Validator.new(example_oas3_schema, {})
        schema = validator.send(:initialize_schema, {})
        original_schema = validator.instance_eval { @original_schema }

        expect(original_schema.object_id).not_to eq(schema.object_id)
        expect(original_schema.schema).to eq(schema.schema)
      end
    end
  end

  describe '.fully_validate' do
    shared_examples :schema_and_path_validation do
      context 'with a schema fragment' do
        let(:options) { {with_schema: 'Pet', oas_version: version} }

        context 'with a valid data' do
          it 'returns no errors' do
            data = YAML.safe_load(File.read("#{data_examples_folder}/pet.json"))

            errors = Validator.fully_validate(schema, data, options)

            expect(errors).to be_empty
          end
        end

        context 'with invalid data' do
          it 'returns errors' do
            data = YAML.safe_load(File.read("#{data_examples_folder}/invalid/pet.json"))

            errors = Validator.fully_validate(schema, data, options)

            expect(errors).not_to be_empty
          end
        end
      end

      context 'with a response path fragment' do
        let(:options) { {with_response: ['/pets/{petId}', :get, 200], oas_version: version} }

        context 'with a valid data' do
          it 'returns no errors' do
            data = YAML.safe_load(File.read("#{data_examples_folder}/pet.json"))

            errors = Validator.fully_validate(schema, data, options)

            expect(errors).to be_empty
          end
        end

        context 'with invalid data' do
          it 'returns errors' do
            data = YAML.safe_load(File.read("#{data_examples_folder}/invalid/pet.json"))

            errors = Validator.fully_validate(schema, data, options)

            expect(errors).not_to be_empty
          end
        end
      end
    end

    context 'with an OAS 3.0 version' do
      let(:schema) { example_oas3_schema }
      let(:version) { JSON::Oas::Version::OAS3 }

      include_examples :schema_and_path_validation

      context 'with a response fragment' do
        let(:options) { {with_response: 'Error', oas_version: version} }

        context 'with a valid data' do
          it 'returns no errors' do
            data = YAML.safe_load(File.read("#{data_examples_folder}/error.json"))

            errors = Validator.fully_validate(schema, data, options)

            expect(errors).to be_empty
          end
        end

        context 'with invalid data' do
          it 'returns errors' do
            data = YAML.safe_load(File.read("#{data_examples_folder}/invalid/error.json"))

            errors = Validator.fully_validate(schema, data, options)

            expect(errors).not_to be_empty
          end
        end
      end
    end

    context 'with an OAS 2.0 version' do
      let(:schema) { example_oas2_schema }
      let(:version) { JSON::Oas::Version::OAS2 }

      include_examples :schema_and_path_validation
    end
  end
end
