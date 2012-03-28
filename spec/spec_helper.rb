require 'rdf'
require 'rdf/spec'
require 'rdf/spec/matchers'
require 'rdf/virtuoso'

RSpec.configure do |config|
  config.include(RDF::Spec::Matchers)
end
