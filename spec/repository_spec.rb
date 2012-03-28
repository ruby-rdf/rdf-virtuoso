require File.join(File.dirname(__FILE__), 'spec_helper')
require 'rdf/spec/repository'

describe RDF::Virtuoso::Repository do

  before :each do
    @repository = RDF::Virtuoso::Repository.new('http://reviewer:secret@localhost:8890/sparql-auth')
  end

  after :each do
    #@repository.clear
  end

  it 'is valid' do
    #puts @statements.inspect
  end

end
