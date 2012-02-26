# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rdf/virtuoso/version"

Gem::Specification.new do |s|
  s.name        = "rdf-virtuoso"
  s.version     = RDF::Virtuoso::VERSION
  s.authors     = ["Peter Kordel"]
  s.email       = ["pkordel@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "rdf-virtuoso"

  s.files         = %w(README.md) + Dir.glob('lib/**/*.rb')
  s.test_files    = %w()
  s.executables   = %w()
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec", "~> 2.8.0"
  s.add_development_dependency "rdf-spec", "~> 0.3.5"

  s.add_runtime_dependency "rdf", "~> 0.3.5"
  s.add_runtime_dependency 'net-http-persistent', '~> 2.5.2'

end
