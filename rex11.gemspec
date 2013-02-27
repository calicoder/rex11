# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rex11/version'

Gem::Specification.new do |gem|
  gem.name          = "rex11"
  gem.version       = Rex11::VERSION
  gem.authors       = ["Andy Shin"]
  gem.email         = ["andrewkshin@gmail.com"]
  gem.description   = "Ruby Library for REX11 Warehouse Management System"
  gem.summary       = "This is a library for interfacing with REX11 Warehouse Management System"
  gem.homepage      = "https://www.vaunte.com"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency('active_utils', '~> 1.0.5')
  gem.add_dependency('builder')
  gem.add_dependency('xml-simple')

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
end
