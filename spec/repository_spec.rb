require File.join(File.dirname(__FILE__), 'spec_helper')
require 'rdf/spec/repository'

describe RDF::Virtuoso::Repository do
  context 'virtuoso' do
    before do
      @repository = RDF::Virtuoso::Repository.new('http://reviewer:secret@localhost:8890/sparql-auth')
    end

    after do
      @repository.clear
    end

    # @see lib/rdf/spec/repository.rb in RDF-spec
    it_should_behave_like RDF_Repository
  end
end
