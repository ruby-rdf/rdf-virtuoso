require 'rdf/spec'
require 'rdf/virtuoso'

RSpec.configure do |config|
  config.include(RDF::Spec::Matchers)
end
