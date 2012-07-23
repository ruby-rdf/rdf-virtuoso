require 'rdf/spec'
require 'rdf'
require 'rdf/virtuoso'
require 'active_rdf'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'fixtures/cassettes'
  c.hook_into :webmock
end

Dir[File.expand_path('../../spec/support/**/*.rb', File.path(__FILE__))].each { |f| require f }

#RSpec.configure do |config|
#  config.include(RDF::Spec::Matchers)
#end
