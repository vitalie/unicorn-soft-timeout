# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'unicorn/soft_timeout/version'

Gem::Specification.new do |spec|
  spec.name          = "unicorn-soft-timeout"
  spec.version       = Unicorn::SoftTimeout::VERSION
  spec.authors       = ["Vitalie Cherpec"]
  spec.email         = ["vitalie@penguin.ro"]
  spec.description   = %q{Graceful handling of requests which are reaching the timeout limit to avoid SIGKILL}
  spec.summary       = %q{Unicorn soft timeout}
  spec.homepage      = "https://github.com/vitalie/unicorn-soft-timeout"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "unicorn", "~> 4"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
