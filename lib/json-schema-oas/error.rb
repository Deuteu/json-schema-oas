module JSON
  module Oas
    # Error raised in JSON::Oas
    class Error < ::StandardError
      INVALID_SCHEMA_ERROR = 'Invalid schema'.freeze
      UNKNOWN_VERSION_ERROR = 'Unknown version'.freeze
    end
  end
end
