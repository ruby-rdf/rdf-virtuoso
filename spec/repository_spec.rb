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

  # from spira base count:
  # 1) queryable.query({:predicate=>#<RDF::URI:0x3fdccfb848a4(http://www.w3.org/1999/02/22-rdf-syntax-ns#type)>, :object=>#<RDF::URI:0x3fdccf9a4714(http://purl.org/stuff/rev#Review)>})
  # 2) pattern = Query::Pattern.from(pattern) #=> <RDF::Query::Pattern:0x3fdcce0e299c( <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/stuff/rev#Review> .)>
  # 3) enum = countable.enum_for(:query_pattern, pattern) #=> #<Enumerator: #<RDF::Virtuoso::Repository:0x3fdcce3075c4(http://data.deichman.no/sparql)>:query_pattern(#<RDF::Query::Pattern:0x3fdcce0e299c( <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/stuff/rev#Review> .)>)>

end
