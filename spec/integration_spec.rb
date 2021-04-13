# frozen_string_literal: true

$LOAD_PATH.unshift '.'
require File.join(File.dirname(__FILE__), 'spec_helper')
require 'rdf/spec/repository'

# these tests rely on a Virtuoso instance being available, at port 8890, and will otherwise fail
# the easiest way to do this is with docker ( https://docs.docker.com/get-docker/ ), running the following:
#   docker run -p 8890:8890 -p 1111:1111 -e DBA_PASSWORD=tester -e SPARQL_UPDATE=true --name virtuoso-testing -d tenforce/virtuoso
# when finished you can stop with
#   docker stop virtuoso-testing

describe RDF::Virtuoso::Repository do
  context('when interacting with a virtuoso repository instance') do
    subject(:repository) do
      described_class.new(uri,
                          update_uri: update_uri,
                          username: username,
                          password: password,
                          auth_method: 'digest')
    end

    let(:uri) { 'http://localhost:8890/sparql' }
    let(:update_uri) { 'http://localhost:8890/sparql-auth' }
    let(:password) { 'tester' }
    let(:username) { 'dba' }
    let(:graph) { 'http://example.org/' }

    it 'is able to select' do
      # check a single triple result which is unlikely to change

      query = RDF::Virtuoso::Query.select.where([RDF::URI('http://localhost:8890/sparql'),
                                                 RDF::URI('http://www.w3.org/ns/sparql-service-description#endpoint'), :o])

      expect(repository.select(query).last.o).to eql RDF::URI('http://localhost:8890/sparql')
    end

    it 'is able to insert' do
      query = RDF::Virtuoso::Query.insert([RDF::URI('subject:person'), RDF::URI('http://purl.org/dc/terms/title'),
                                           'The title']).graph(graph)
      expect(repository.insert(query)).to eql 'Insert into <http://example.org/>, 1 (or less) triples -- done'

      # #clean up
      query = RDF::Virtuoso::Query.delete([RDF::URI('subject:person'), :p,
                                           :o]).where([RDF::URI('subject:person'), :p, :o]).graph(graph)
      repository.delete(query)
    end

    # it_behaves_like "an RDF::Repository" do
    #     let(:repository) {subject}
    # end
  end
end
