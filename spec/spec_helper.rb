require 'bundler/setup'
require 'rspec'
require 'rdf'
require 'rdf/spec'
require 'rdf/spec/matchers'
require 'rdf/virtuoso'
require 'rdf/vocab'

RSpec.configure do |config|
  config.include(RDF::Spec::Matchers)
end
