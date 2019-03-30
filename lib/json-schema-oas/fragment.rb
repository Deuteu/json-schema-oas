module JSON
  module Oas
    # This is a workaround for json-schema's fragment validation
    # which does not allow to contain forward slashes
    # due to an attempt split('/')
    class Fragment < Array
      class << self
        def response_schema_for(version, path_or_name, method = nil, code = nil)
          case version
          when Version::OAS2
            raise ArgumentError unless method && code

            new(['#', 'paths', path_or_name, method.to_s, 'responses', code.to_s, 'schema'])
          when Version::OAS3
            v3_response_schema_for(path_or_name, method, code)
          else
            raise Error, Error::UNKNOWN_VERSION_ERROR
          end
        end

        def schema_for(version, name)
          case version
          when Version::OAS2
            new(['#', 'definitions', name.to_s])
          when Version::OAS3
            new(['#', 'components', 'schemas', name.to_s])
          else
            raise Error, Error::UNKNOWN_VERSION_ERROR
          end
        end

        private

        # @path_or_name String To avoid https://github.com/ruby-json-schema/json-schema/issues/229
        def v3_response_schema_for(path_or_name, method = nil, code = nil)
          unless method && code
            raise ArgumentError unless path_or_name

            return new(['#', 'components', 'responses', path_or_name, 'content', 'application/json', 'schema'])
          end

          v3_paths_response_schema_for(path_or_name, method, code)
        end

        def v3_paths_response_schema_for(path, method, code)
          raise ArgumentError unless method && code && path

          new(['#', 'paths', path, method.to_s, 'responses', code.to_s, 'content', 'application/json', 'schema'])
        end
      end

      def split(_options = nil)
        dup
      end
    end
  end
end
