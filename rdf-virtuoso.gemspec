# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'rdf/virtuoso/version'

Gem::Specification.new do |s|
  s.name        = 'rdf-virtuoso'
  s.version     = RDF::Virtuoso::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Peter Kordel']
  s.email       = ['pkordel@gmail.com']
  s.homepage    = 'https://github.com/pkordel/rdf-virtuoso'
  s.summary     = %q{A library for interacting with a Virtuoso rdf store}
  s.description = %q{A library for interacting with a Virtuoso rdf store}

  s.rubyforge_project = 'rdf-virtuoso'

  s.files         = %w(README.md) + Dir.glob('lib/**/*.rb')
  s.require_paths = ['lib']

  s.add_development_dependency 'rspec', '~> 2.8.0'
  s.add_development_dependency 'rdf-spec', '~> 0.3.5'
  s.add_development_dependency 'vcr'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'debugger'

  # TODO: see about range of versions, e.g. >= 3.0.2, < 4.1
  s.add_runtime_dependency 'activesupport', '~> 3.2.3'
  s.add_runtime_dependency 'active_attr'
  s.add_runtime_dependency 'uuid', '~> 2.3.5'
  s.add_runtime_dependency 'transaction-simple', '~> 1.4.0'

  s.add_runtime_dependency 'rdf', '~> 0.3.5'
  s.add_runtime_dependency 'httparty', '0.8.2'
  s.add_runtime_dependency 'api_smith'

end
