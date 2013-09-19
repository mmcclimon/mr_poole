# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mr_poole/version'

Gem::Specification.new do |spec|
  spec.name          = "mr_poole"
  spec.version       = MrPoole::VERSION
  spec.authors       = ["Michael McClimon"]
  spec.email         = ["michael@mcclimon.org"]
  spec.description   = %q{Helper for Jekyll}
  spec.summary       = %q{Does stuff for Jekyll}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
