$:.unshift "."
require File.join(File.dirname(__FILE__), 'spec_helper')
require 'rdf/spec/repository'

#require_relative '../lib/rdf/virtuoso/repository'

describe RDF::Virtuoso::Repository do

  before(:each) do
    @uri = "http://localhost:8890/sparql"
    @update_uri = "http://localhost:8890/sparql-auth"
    @repository = RDF::Virtuoso::Repository.new(@uri)
  end

    #include RDF_Repository  # not implemented
      
    it "should support connecting to a Virtuoso SPARQL endpoint" do
      repo = RDF::Virtuoso::Repository.new(@uri)
      repo.instance_variable_get("@sparul_endpoint").should == "/sparql"
    end

    it "should support accept port in repository endpoint" do
      repo = RDF::Virtuoso::Repository.new(@uri)
      repo.instance_variable_get("@base_uri").should == "http://localhost:8890"
    end
        
    it "should support connecting to a Virtuoso SPARUL endpoint with BASIC AUTH" do
      repo = RDF::Virtuoso::Repository.new(@uri, :update_uri => @update_uri, :username => 'admin', :password => 'secret', :auth_method => 'basic')
      repo.instance_variable_get("@auth_method").should == "basic"
    end
    
    it "should support connecting to a Virtuoso SPARUL endpoint with DIGEST AUTH" do
      repo = RDF::Virtuoso::Repository.new(@uri, :update_uri => @update_uri, :username => 'admin', :password => 'secret', :auth_method => 'digest')
      repo.instance_variable_get("@sparul_endpoint").should == "/sparql-auth"
    end
    
    it "should support timeout option" do
      repo = RDF::Virtuoso::Repository.new(@uri, :timeout => 10)
      repo.instance_variable_get("@timeout").should == 10
    end
    
    it "should support custom query" do
      q = "CONSTRUCT {?s a rdf:resource} WHERE {?s a ?type} LIMIT 1"
      repo = RDF::Virtuoso::Repository.new(@uri, :update_uri => @update_uri, :username => 'dba', :password => 'virtuoso99admin', :auth_method => 'digest')
      result = repo.query(q)
      result.first[:p].should == RDF.type
    end
end
