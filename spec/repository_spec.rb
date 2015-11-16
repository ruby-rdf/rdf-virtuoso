$:.unshift "."
require File.join(File.dirname(__FILE__), 'spec_helper')
require 'rdf/spec/repository'

#require_relative '../lib/rdf/virtuoso/repository'

describe RDF::Virtuoso::Repository do
  let(:uri) {"http://localhost:8890/sparql"}
  let(:update_uri) {"http://localhost:8890/sparql-auth"}
  let(:repo) {RDF::Virtuoso::Repository.new(uri)}

  #include RDF_Repository  # not implemented
    
  it "should support connecting to a Virtuoso SPARQL endpoint" do
    expect(repo.instance_variable_get("@sparul_endpoint")).to eql "/sparql"
  end

  it "should support accept port in repository endpoint" do
    expect(repo.instance_variable_get("@base_uri")).to eql "http://localhost:8890"
  end
      
  it "should support connecting to a Virtuoso SPARUL endpoint with BASIC AUTH" do
    repo = RDF::Virtuoso::Repository.new(uri, update_uri: update_uri, username: 'admin', password: 'secret', auth_method: 'basic')
    expect(repo.instance_variable_get("@auth_method")).to eql "basic"
  end
  
  it "should support connecting to a Virtuoso SPARUL endpoint with DIGEST AUTH" do
    repo = RDF::Virtuoso::Repository.new(uri, update_uri: update_uri, username: 'admin', password: 'secret', auth_method: 'digest')
    expect(repo.instance_variable_get("@sparul_endpoint")).to eql "/sparql-auth"
  end
  
  it "should support timeout option" do
    repo = RDF::Virtuoso::Repository.new(uri, timeout: 10)
    expect(repo.instance_variable_get("@timeout")).to eql 10
  end
 end
