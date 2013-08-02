# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "erbac/version"

Gem::Specification.new do |s|
  s.name        = 'erbac'
  s.version     = Erbac::VERSION.dup
  s.date        = '2013-07-16'
  s.summary     = "Yii rbac transplatation!"
  s.description = "A simple hello world gem"
  
  s.authors     = ["dx"]
  s.email       = 'bitcheap@gmail.com'
  s.homepage    = 'http://utocity.com'
  
  s.files       = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]
  
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', ">= 2.0"
  s.add_development_dependency "rspec-rails", ">= 2.0"
  s.add_development_dependency "bundler"
  s.add_development_dependency "activerecord", ">= 3.2.0"
  
 

end
