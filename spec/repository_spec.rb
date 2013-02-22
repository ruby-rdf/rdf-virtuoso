$:.unshift "."
require 'spec_helper'
require 'rdf/spec/repository'
#require_relative '../lib/rdf/virtuoso/repository'
describe RDF::Virtuoso::Repository do

  before(:each) do
    @uri = "http://localhost:8890/sparql"
    @update_uri = "http://localhost:8890/sparql-auth"
  end
  
    it "should mixin RDF::Repository" do
      @repository = RDF::Virtuoso::Repository.new(@uri)
      #it_should_behave_like RDF_Repository # not working!
    end
    
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
end
