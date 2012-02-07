# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "serious/version"

Gem::Specification.new do |s|
  s.name        = "serious"
  s.version     = SERIOUS_VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = [ "Dmitry A. Ustalov", "Christoph Olszowka" ]
  s.email       = [ "dmitry@eveel.ru", "christoph at olszowka de" ]
  s.homepage    = "https://github.com/eveel/serious"
  s.summary     = %Q{Serious is a simple, file-driven blog engine that is driven by Sinatra}
  s.description = %Q{Serious is a simple, file-driven blog engine inspired by Toto and driven by Sinatra with an emphasis on easy setup}

  s.rubyforge_project = "serious"

  s.bindir = 'bin'
  s.executables = ['serious']

  s.add_dependency 'sinatra', ">= 1.0.0"
  s.add_dependency 'stupid_formatter', '>= 0.2.0'
  s.add_dependency 'builder', ">= 2.1.2"

  s.add_development_dependency "shoulda", "~> 2.11"
  s.add_development_dependency "nokogiri", "~> 1.5"
  s.add_development_dependency "rack-test", ">= 0.5"
  s.add_development_dependency "rake", ">= 0.8.7"
  s.add_development_dependency "rdoc"
  s.add_development_dependency "simplecov", "~> 0.5"
  s.add_development_dependency "i18n", ">= 0.6.0"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
