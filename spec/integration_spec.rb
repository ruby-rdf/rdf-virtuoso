$:.unshift '.'
require File.join(File.dirname(__FILE__), 'spec_helper')
require 'rdf/spec/repository'

# these tests rely on a Virtuoso instance being available, at port 8890, and will otherwise fail
# the easiest way to do this is with docker ( https://docs.docker.com/get-docker/ ), running the following:
#   docker run -p 8890:8890 -p 1111:1111 -e DBA_PASSWORD=tester -e SPARQL_UPDATE=true --name virtuoso-testing -d tenforce/virtuoso
# when finished you can stop with
#   docker stop virtuoso-testing

describe RDF::Virtuoso::Repository do
  context('when interating with a virtuoso repository instance') do
    let(:uri) { 'http://localhost:8890/sparql' }
    let(:update_uri) { 'http://localhost:8890/sparql-auth' }
    let(:repo) { RDF::Virtuoso::Repository.new(uri) }
    let(:password) { 'tester' }
    let(:username) { 'dba' }
    let(:repo) do
      RDF::Virtuoso::Repository.new(uri,
                                    update_uri: update_uri,
                                    username: username,
                                    password: password,
                                    auth_method: 'digest')
    end

    it 'should be able to select' do
      query = RDF::Virtuoso::Query.select.where([RDF::Resource('http://localhost:8890/sparql'), :p, :o])
      expect(repo.select(query).count).to eql 14
    end

    it_behaves_like "an RDF::Repository" do
        let(:repository) {repo}
    end
  end
end
