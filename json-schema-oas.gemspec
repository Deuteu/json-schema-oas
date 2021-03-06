lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'json-schema-oas/schema/version'

Gem::Specification.new do |spec|
  spec.name          = 'json-schema-oas'
  spec.version       = JSON::Oas::Schema::VERSION
  spec.authors       = ['Guillaume Dt']
  spec.email         = ['Deuteu@users.noreply.github.com']
  spec.license       = 'Apache-2.0'

  spec.summary       = 'Ruby JSON Schema Validator with OAS helper'
  spec.homepage      = 'https://github.com/Deuteu/json-schema-oas'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'json-schema', '~> 2.8', '>= 2.8.1'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.65'
  spec.add_development_dependency 'simplecov', '~> 0.16'
end
