# -*- encoding: utf-8 -*-
require File.expand_path('../lib/carabiner/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["mordaroso"]
  gem.email         = ["mordaroso@gmail.com"]
  gem.homepage      = 'http://rubygems.org/gems/carabiner'
  gem.summary       = 'Rubymotion wrapper for the keychain'
  gem.description   = 'Easy access to the ios keychain'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "carabiner"
  gem.require_paths = ["lib"]
  gem.version       = Carabiner::VERSION

  gem.add_dependency 'rake'
  gem.add_dependency 'bubble-wrap'
  gem.add_dependency 'motion-require', '~> 0.0.3'

  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'guard-motion'
end
