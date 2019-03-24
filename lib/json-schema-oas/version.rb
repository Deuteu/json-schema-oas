module JSON
  module Oas
    class Version
      OAS2 = '2.0'.freeze
      OAS3 = '3.0'.freeze

      DEFAULT_VERSION = OAS3
      VERSIONS = [OAS2, OAS3].freeze
    end
  end
end
