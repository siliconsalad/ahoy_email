# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ahoy_email/version"

Gem::Specification.new do |spec|
  spec.name          = "ahoy_email"
  spec.version       = AhoyEmail::VERSION
  spec.authors       = ["Andrew Kane", "Alexandre Salaun"]
  spec.email         = ["asalaun@siliconsalad.com"]
  spec.summary       = "Simple, powerful email tracking for Rails"
  spec.description   = "Simple, powerful email tracking for Rails"
  spec.homepage      = "https://github.com/siliconsalad/ahoy_email"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rails"
  spec.add_dependency "addressable"
  spec.add_dependency "nokogiri"
  spec.add_dependency "httparty"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
