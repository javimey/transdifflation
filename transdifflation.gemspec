# -*- encoding: utf-8 -*-
require File.expand_path('../lib/transdifflation/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Steve Belicha & Javier Mey"]
  gem.email         = ["steve.belicha@sage.com; javier.mey@sage.com"]
  gem.description   = %q{Compares yml locate files with yours and generate diff files to maintain gems or adjacent projects }
  gem.summary       = %q{Compares yml locate files with yours and generate diff files to maintain gems or adjacent projects}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "transdifflation"
  gem.require_paths = ["lib"]
  gem.version       = "0.0.1"

  #Dependencies
  gem.add_dependency 'rails', '~> 3.2.8'

  gem.add_development_dependency 'rspec', '>= 2.8.0'
  gem.add_development_dependency 'guard-rspec'
  gem.add_development_dependency 'yard'
  gem.add_development_dependency 'redcarpet'
  gem.add_development_dependency 'RedCloth'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'rb-inotify'
  gem.add_development_dependency 'libnotify'
  gem.add_development_dependency 'pry'
end

