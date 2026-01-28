# frozen_string_literal: true

require_relative "lib/ghost/version"

Gem::Specification.new do |spec|
  spec.name = "ghost-ruby"
  spec.version = Ghost::VERSION
  spec.authors = ["Ronald Langeveld"]
  spec.summary = "Ruby SDK for the Ghost CMS API"
  spec.description = "Ruby client for the Ghost Content API and Admin API. Supports browsing, reading, creating, editing, deleting resources and file uploads."
  spec.homepage = "https://github.com/ronaldlangeveld/ghost-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.files = Dir["lib/**/*.rb"]
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 2.7"
  spec.add_dependency "faraday-multipart", "~> 1.0"
  spec.add_dependency "jwt", "~> 2.7"
end
