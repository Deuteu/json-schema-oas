require 'json-schema'

module JSON
  module Oas
    OAS2_SCHEMA_PATH = File.expand_path('../../data/specifications/oas2.json', __dir__)
    OAS3_SCHEMA_PATH = File.expand_path('../../data/specifications/oas3.json', __dir__)

    # Validator to validate data against a OpenAPI schema
    class Validator < JSON::Validator
      class << self
        def valid_schema?(schema, version)
          specs = case version
                  when Version::OAS2
                    OAS2_SCHEMA_PATH
                  when Version::OAS3
                    OAS3_SCHEMA_PATH
                  else
                    raise Error, Error::UNKNOWN_VERSION_ERROR
                  end
          JSON::Validator.fully_validate(specs, schema).empty?
        end

        def compute_fragment(version, opts)
          options = Hash(opts)
          return options if options[:fragment]

          if options[:with_schema]
            options[:fragment] = Fragment.schema_for(version, options[:with_schema].to_s)
          elsif options[:with_response]
            options[:fragment] = Fragment.response_schema_for(version, *Array(options[:with_response]))
          end

          options
        end
      end

      private

      def initialize(schema_data, data, opts = {})
        @original_schema = schema_data.dup

        @oas_version = opts[:oas_version] || Oas::Version::DEFAULT_VERSION
        raise Error, Error::UNKNOWN_VERSION_ERROR unless Oas::Version::VERSIONS.include?(@oas_version)

        options = self.class.compute_fragment(@oas_version, opts)

        super(schema_data, data, options)

        validate_schema!
      end

      def initialize_schema(schema)
        schema = super(schema)
        @original_schema = schema.dup
        schema
      end

      def validate_schema!
        return true if self.class.valid_schema?(@original_schema.schema, @oas_version)

        raise Error, Error::INVALID_SCHEMA_ERROR
      end
    end
  end
end
