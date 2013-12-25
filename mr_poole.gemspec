# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mr_poole/version'

Gem::Specification.new do |spec|
  spec.name          = "mr_poole"
  spec.version       = MrPoole::VERSION
  spec.authors       = ["Michael McClimon"]
  spec.email         = ["michael@mcclimon.org"]
  spec.description   = %q{A butler for Jekyll, provides interface for creating posts/drafts}
  spec.summary       = <<-EOF
    A butler for Jekyll. Provides a command-line interface (called `poole`) for
    creating and publishing posts and drafts for Jekyll (http://jekyllrb.com)
    blogs.

    The literary Mr. Poole is Jekyll's butler, who "serves Jekyll faithfully, and
    attempts to do a good job and be loyal to his master"
    (http://en.wikipedia.org/wiki/Jekyll_and_hyde#Mr._Poole), and the
    Mr. Poole gem looks to be the same thing.
  EOF
  spec.homepage      = "http://github.com/mmcclimon/mr_poole"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rake"

  if RUBY_VERSION > '1.9'
    spec.add_development_dependency('coveralls', "~> 0.6.9")
  end
end
