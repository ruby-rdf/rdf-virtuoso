# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'rdf/virtuoso/version'

Gem::Specification.new do |s|
  s.name        = 'rdf-virtuoso'
  s.version     = RDF::Virtuoso::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Benjamin Rokseth', 'Peter Kordel']
  s.email       = ['benjamin.rokseth@kul.oslo.kommune.no']
  s.homepage    = 'https://github.com/digibib/rdf-virtuoso'
  s.summary     = %q{An RDF.rb extension library for interacting with a Virtuoso rdf store}
  s.description = %q{An RDF.rb extension library for interacting with a Virtuoso rdf store}

  s.rubyforge_project = 'rdf-virtuoso'

  s.files         = %w(README.md) + Dir.glob('lib/**/*.rb')
  s.files        += Dir['spec/**/*.rb'] + Dir['doc/**/**/*.rb']
  s.require_paths = ['lib']

  s.add_development_dependency 'rspec'#, '~> 2.13.0'
  s.add_development_dependency 'rdf-spec'#, '~> 1.0.0'

  s.add_runtime_dependency 'rdf'#, '~> 1.0.3'
  s.add_runtime_dependency 'httparty'#, '~> 0.10.2'
  s.add_runtime_dependency 'api_smith'#, '~> 1.2.0'

end
