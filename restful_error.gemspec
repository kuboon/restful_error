# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "restful_error/version"

Gem::Specification.new do |spec|
  spec.name = "restful_error"
  spec.version = RestfulError::VERSION
  spec.required_ruby_version = ">= 3.1"
  spec.authors = [ "kuboon" ]
  spec.email = [ "o@kbn.one" ]
  spec.summary = "Define your error with status code. Raise it and you will get formatted response with i18nized message."
  spec.description = "Define status_code method on your error. Views and messages are fully customizable on rails way."
  spec.homepage = "https://github.com/kuboon/restful_error"
  spec.license = "MIT"

  spec.files = Dir["**/*.rb"]
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = [ "lib" ]

  spec.add_dependency "rack", "> 2"

  spec.metadata["rubygems_mfa_required"] = "true"
end
