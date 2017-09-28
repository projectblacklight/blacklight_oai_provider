 # -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), "lib/blacklight_oai_provider/version")

Gem::Specification.new do |s|
  s.name = "blacklight_oai_provider"
  s.version = BlacklightOaiProvider::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Chris Beer"]
  s.email = ["chris@cbeer.info"]
  s.homepage    = "http://projectblacklight.org/"
  s.summary = "Blacklight Oai Provider plugin"

  s.rubyforge_project = "blacklight"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "rails", "~> 4.0"
  s.add_dependency "blacklight", "~> 4.0"
  s.add_dependency "oai"
  s.add_development_dependency 'rspec-rails', "~> 3.0"
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'solr_wrapper'
  s.add_development_dependency 'engine_cart'
end
