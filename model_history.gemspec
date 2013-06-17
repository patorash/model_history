# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'model_history/version'

Gem::Specification.new do |spec|
  spec.name          = 'model_history'
  spec.version       = ModelHistory::VERSION
  spec.authors       = ['patorash']
  spec.email         = ['chariderpato@gmail.com']
  spec.description   = %q{Model History is a simple gem that allows you to keep track of changes to specific fields in your Rails models using the ActiveRecord::Dirty module.}
  spec.summary       = %q{Model History is a simple gem that allows you to keep track of changes to specific fields in your Rails models using the ActiveRecord::Dirty module.}
  spec.homepage      = 'https://github.com/patorash/model_history'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'activerecord'
  spec.add_development_dependency 'sqlite3'
  spec.add_dependency 'rails', '>= 3.2.13'
end
