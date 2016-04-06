# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ssh_client/version'

Gem::Specification.new do |spec|
  spec.name          = "ssh_client"
  spec.version       = SSHClient::VERSION
  spec.authors       = ["Konstantin Kosmatov"]
  spec.email         = ["key@kosmatov.ru"]

  spec.summary       = %q{Ruby SSH client}
  spec.description   = %q{Ruby SSH client using Open3 and OpenSSH to interact with any remote shell}
  spec.homepage      = "https://github.com/kosmatov/ssh_client"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry", "~> 0"
  spec.add_development_dependency "coveralls", "~> 0"
end
