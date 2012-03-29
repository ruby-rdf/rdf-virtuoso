require 'rdf/spec'
require 'rdf/virtuoso'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'fixtures/cassettes'
  c.hook_into :webmock
end

RSpec.configure do |config|
  config.include(RDF::Spec::Matchers)
end
