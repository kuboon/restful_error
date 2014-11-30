# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'restful_error/version'

Gem::Specification.new do |spec|
  spec.name          = "restful_error"
  spec.version       = RestfulError::VERSION
  spec.authors       = ["kuboon"]
  spec.email         = ["ohkubo@magician.jp"]
  spec.summary       = %q{Define your error with status code. Raise it and you will get formatted response with i18nized message.}
  spec.description   = %q{Define your error with status code. Raise it and you will get formatted response with i18nized message.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'rails', "> 3.1"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
