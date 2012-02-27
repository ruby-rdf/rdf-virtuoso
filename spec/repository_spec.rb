require File.join(File.dirname(__FILE__), 'spec_helper')
require 'rdf/spec/repository'

describe RDF::Virtuoso::Repository do
  context 'virtuoso' do
    before :each do
      @repository = RDF::Virtuoso::Repository.new('http://reviewer:secret@localhost:8890/sparql-auth')
      @filename   = File.expand_path(File.join(File.dirname(__FILE__), '..', 'etc', 'doap.nt'))
      @statements = RDF::NTriples::Reader.new(File.open(@filename)).to_a
      @enumerable = @repository
    end

    after :each do
      #@repository.clear
    end

    it 'is valid' do
      #puts @statements.inspect
    end

    # @see lib/rdf/spec/repository.rb in RDF-spec
    #it_should_behave_like RDF_Repository
    #
    context "when counting statements" do
      require 'rdf/spec/countable'

      before :each do
        @countable = @repository
        @countable.insert(*@statements)
      end

      it_should_behave_like RDF_Countable
    end
  end

end
