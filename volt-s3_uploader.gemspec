# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'volt/s3_uploader/version'

Gem::Specification.new do |spec|
  spec.name          = "volt-s3_uploader"
  spec.version       = Volt::S3Uploader::VERSION
  spec.authors       = ["Ryan Stout"]
  spec.email         = ["ryanstout@gmail.com"]
  spec.summary       = %q{TODO: Write a short summary. Required.}
  spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'aws-sdk', '~> 2.1.15'
  spec.add_development_dependency "volt", "~> 0.9.5.0"
  spec.add_development_dependency 'rspec', '~> 3.2.0'
  spec.add_development_dependency "rake"
end
