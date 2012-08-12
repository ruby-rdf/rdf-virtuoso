require_relative '../lib/rdf/virtuoso/repository'
describe RDF::Virtuoso do

  before(:each) do
    @uri = "http://localhost:8890"
  end

  context "when connecting to a Virtuoso server" do
    it "should support connecting to a Virtuoso SPARQL endpoint" do
      RDF::Virtuoso::Repository.new(@uri)
    end
    
    it "should support connecting to a Virtuoso SPARUL endpoint with BASIC AUTH" do
      RDF::Virtuoso::Repository.new(@uri, :username => 'admin', :password => 'secret', :auth_method => 'basic')
    end
    
    it "should support connecting to a Virtuoso SPARUL endpoint with DIGEST AUTH" do
      RDF::Virtuoso::Repository.new(@uri, :username => 'admin', :password => 'secret', :auth_method => 'digest')
    end
  end
end
