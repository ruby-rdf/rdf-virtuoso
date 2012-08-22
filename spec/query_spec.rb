require File.join(File.dirname(__FILE__), 'spec_helper')

describe RDF::Virtuoso::Query do
  before :each do
    @query = RDF::Virtuoso::Query
  end

  context "when building queries" do
    it "should support ASK queries" do
      @query.should respond_to(:ask)
    end

    it "should support SELECT queries" do
      @query.should respond_to(:select)
    end

    it "should support DESCRIBE queries" do
      @query.should respond_to(:describe)
    end

    it "should support CONSTRUCT queries" do
      @query.should respond_to(:construct)
    end

    it "should support INSERT DATA queries" do
      @query.should respond_to(:insert_data)
    end

    it "should support INSERT WHERE queries" do
      @query.should respond_to(:insert)
    end
    
    it "should support DELETE DATA queries" do
      @query.should respond_to(:delete_data)
    end

    it "should support DELETE WHERE queries" do
      @query.should respond_to(:delete)
    end

    it "should support CREATE GRAPH queries" do
      @query.should respond_to(:create)
    end

  end


  context "when building update queries" do
    before :each do
      @graph = "http://example.org/"
      @uri = RDF::Vocabulary.new "http://example.org/"
    end
    # TODO add support for advanced inserts (moving copying between different graphs)
    it "should support INSERT DATA queries" do
      @query.insert_data([@uri.ola, @uri.type, @uri.something]).graph(RDF::URI.new(@graph)).to_s.should == "INSERT DATA INTO GRAPH <#{@graph}> { <#{@graph}ola> <#{@graph}type> <#{@graph}something> . }"
      @query.insert_data([@uri.ola, @uri.name, "two words"]).graph(RDF::URI.new(@graph)).to_s.should == "INSERT DATA INTO GRAPH <#{@graph}> { <#{@graph}ola> <#{@graph}name> \"two words\" . }"
    end

    it "should support INSERT DATA queries with arrays" do
      @query.insert_data([@uri.ola, @uri.type, @uri.something],[@uri.ola, @uri.type, @uri.something_else]).graph(RDF::URI.new(@graph)).to_s.should == "INSERT DATA INTO GRAPH <#{@graph}> { <#{@graph}ola> <#{@graph}type> <#{@graph}something> . <#{@graph}ola> <#{@graph}type> <#{@graph}something_else> . }"
    end
    
    it "should support INSERT DATA queries with RDF::Statements" do
      statements = [RDF::Statement.new(RDF::URI('http://test'), RDF.type, RDF::URI('http://type')), RDF::Statement.new(RDF::URI('http://test'), RDF.type, RDF::URI('http://type2'))]
      @query.insert_data(statements).graph(RDF::URI.new(@graph)).to_s.should == "INSERT DATA INTO GRAPH <#{@graph}> { <http://test> <#{RDF.type}> <http://type> .\n <http://test> <#{RDF.type}> <http://type2> .\n }"
    end
    
    it "should support INSERT WHERE queries with symbols and patterns" do
      @query.insert([:s, :p, :o]).graph(RDF::URI.new(@graph)).where([:s, :p, :o]).to_s.should == "INSERT INTO GRAPH <#{@graph}> { ?s ?p ?o . } WHERE { ?s ?p ?o . }"
      @query.insert([:s, @uri.newtype, :o]).graph(RDF::URI.new(@graph)).where([:s, @uri.type, :o]).to_s.should == "INSERT INTO GRAPH <#{@graph}> { ?s <#{@graph}newtype> ?o . } WHERE { ?s <#{@graph}type> ?o . }"
    end

    it "should support DELETE DATA queries" do
      @query.delete_data([@uri.ola, @uri.type, @uri.something]).graph(RDF::URI.new(@graph)).to_s.should == "DELETE DATA FROM <#{@graph}> { <#{@graph}ola> <#{@graph}type> <#{@graph}something> . }"  
      @query.delete_data([@uri.ola, @uri.name, RDF::Literal.new("myname")]).graph(RDF::URI.new(@graph)).to_s.should == "DELETE DATA FROM <#{@graph}> { <#{@graph}ola> <#{@graph}name> \"myname\" . }"  
    end

    it "should support DELETE DATA queries with arrays" do
      @query.delete_data([@uri.ola, @uri.type, @uri.something],[@uri.ola, @uri.type, @uri.something_else]).graph(RDF::URI.new(@graph)).to_s.should == "DELETE DATA FROM <#{@graph}> { <#{@graph}ola> <#{@graph}type> <#{@graph}something> . <#{@graph}ola> <#{@graph}type> <#{@graph}something_else> . }"
    end
    
    it "should support DELETE DATA queries with RDF::Statements" do
      statements = [RDF::Statement.new(RDF::URI('http://test'), RDF.type, RDF::URI('http://type')), RDF::Statement.new(RDF::URI('http://test'), RDF.type, RDF::URI('http://type2'))]
      @query.delete_data(statements).graph(RDF::URI.new(@graph)).to_s.should == "DELETE DATA FROM <#{@graph}> { <http://test> <#{RDF.type}> <http://type> .\n <http://test> <#{RDF.type}> <http://type2> .\n }"
    end

    it "should support DELETE DATA queries with appendable objects" do
      statements = []
      statements << RDF::Statement.new(RDF::URI('http://test'), RDF.type, RDF::URI('http://type'))
      statements << RDF::Statement.new(RDF::URI('http://test'), RDF.type, RDF::URI('http://type2'))
      @query.delete_data(statements).graph(RDF::URI.new(@graph)).to_s.should == "DELETE DATA FROM <#{@graph}> { <http://test> <#{RDF.type}> <http://type> .\n <http://test> <#{RDF.type}> <http://type2> .\n }"
    end
        
    it "should support DELETE WHERE queries with symbols and patterns" do
      @query.delete([:s, :p, :o]).graph(RDF::URI.new(@graph)).where([:s, :p, :o]).to_s.should == "DELETE FROM <#{@graph}> { ?s ?p ?o . } WHERE { ?s ?p ?o . }"
      @query.delete([:s, @uri.newtype, :o]).graph(RDF::URI.new(@graph)).where([:s, @uri.newtype, :o]).to_s.should == "DELETE FROM <#{@graph}> { ?s <#{@graph}newtype> ?o . } WHERE { ?s <#{@graph}newtype> ?o . }"
    end

    it "should support CREATE GRAPH queries" do
      @query.create(RDF::URI.new(@graph)).to_s.should == "CREATE GRAPH <#{@graph}>"
      @query.create(RDF::URI.new(@graph), :silent => true).to_s.should == "CREATE SILENT GRAPH <#{@graph}>"
    end

    it "should support DROP GRAPH queries" do
      @query.drop(RDF::URI.new(@graph)).to_s.should == "DROP GRAPH <#{@graph}>"
      @query.drop(RDF::URI.new(@graph), :silent => true).to_s.should == "DROP SILENT GRAPH <#{@graph}>"

    end

  end

  context "when building ASK queries" do
    it "should support basic graph patterns" do
      @query.ask.where([:s, :p, :o]).to_s.should == "ASK WHERE { ?s ?p ?o . }"
      @query.ask.whether([:s, :p, :o]).to_s.should == "ASK WHERE { ?s ?p ?o . }"
    end
  end

  context "when building SELECT queries" do
    it "should support basic graph patterns" do
      @query.select.where([:s, :p, :o]).to_s.should == "SELECT * WHERE { ?s ?p ?o . }"
    end

    it "should support projection" do
      @query.select(:s).where([:s, :p, :o]).to_s.should == "SELECT ?s WHERE { ?s ?p ?o . }"
      @query.select(:s, :p).where([:s, :p, :o]).to_s.should == "SELECT ?s ?p WHERE { ?s ?p ?o . }"
      @query.select(:s, :p, :o).where([:s, :p, :o]).to_s.should == "SELECT ?s ?p ?o WHERE { ?s ?p ?o . }"
    end

    it "should support SELECT from NAMED GRAPH" do
      @graph = RDF::URI("http://example.org/")
      @query.select(:s).where([:s, :p, :o]).from(@graph).to_s.should == "SELECT ?s FROM <#{@graph}> WHERE { ?s ?p ?o . }"
    end
    
    it "should support SELECT with complex WHERE patterns" do
      @query.select.where(
      [:s, :p, :o], 
      [:s, RDF.type, RDF::DC.Document]
      ).to_s.should == 
        "SELECT * WHERE { ?s ?p ?o . ?s <#{RDF.type}> <#{RDF::DC.Document}> . }"
    end

    it "should support SELECT WHERE patterns from different GRAPH contexts" do
      @graph1 = "http://example1.org/"
      @graph2 = "http://example2.org/"
      @query.select.where([:s, :p, :o, :context => @graph1],[:s, RDF.type, RDF::DC.Document, :context => @graph2]).to_s.should == 
        "SELECT * WHERE { GRAPH <#{@graph1}> { ?s ?p ?o . } GRAPH <#{@graph2}> { ?s <#{RDF.type}> <#{RDF::DC.Document}> . } }"
    end
        
    it "should support string objects in SPARQL queries" do
      @query.select.where([:s, :p, "dummyobject"]).to_s.should == "SELECT * WHERE { ?s ?p \"dummyobject\" . }"
    end

    #it "should support raw string SPARQL queries" do
    #  q = "SELECT * WHERE { ?s <#{RDF.type}> ?o . }"
    #  @query.query(q).should == "SELECT * WHERE { ?s <#{RDF.type}> ?o . }"
    #end

    it "should support FROM" do
      uri = "http://example.org/dft.ttl"
      @query.select.from(RDF::URI.new(uri)).where([:s, :p, :o]).to_s.should ==
        "SELECT * FROM <#{uri}> WHERE { ?s ?p ?o . }"
    end

    it "should support DISTINCT" do
      @query.select(:s, :distinct => true).where([:s, :p, :o]).to_s.should == "SELECT DISTINCT ?s WHERE { ?s ?p ?o . }"
      @query.select(:s).distinct.where([:s, :p, :o]).to_s.should == "SELECT DISTINCT ?s WHERE { ?s ?p ?o . }"
    end

    it "should support REDUCED" do
      @query.select(:s, :reduced => true).where([:s, :p, :o]).to_s.should == "SELECT REDUCED ?s WHERE { ?s ?p ?o . }"
      @query.select(:s).reduced.where([:s, :p, :o]).to_s.should == "SELECT REDUCED ?s WHERE { ?s ?p ?o . }"
    end

    it "should support aggregate COUNT" do
      @query.select.where([:s, :p, :o]).count(:s).to_s.should == "SELECT (COUNT (?s) AS ?s) WHERE { ?s ?p ?o . }"
      @query.select.count(:s).where([:s, :p, :o]).to_s.should == "SELECT (COUNT (?s) AS ?s) WHERE { ?s ?p ?o . }"
    end

    it "should support aggregates SUM, MIN, MAX, AVG, SAMPLE, GROUP_CONCAT, GROUP_DIGEST" do
      @query.select.where([:s, :p, :o]).sum(:s).to_s.should == "SELECT (SUM (?s) AS ?s) WHERE { ?s ?p ?o . }"
      @query.select.where([:s, :p, :o]).min(:s).to_s.should == "SELECT (MIN (?s) AS ?s) WHERE { ?s ?p ?o . }"
      @query.select.where([:s, :p, :o]).max(:s).to_s.should == "SELECT (MAX (?s) AS ?s) WHERE { ?s ?p ?o . }"
      @query.select.where([:s, :p, :o]).avg(:s).to_s.should == "SELECT (AVG (?s) AS ?s) WHERE { ?s ?p ?o . }"
      @query.select.where([:s, :p, :o]).sample(:s).to_s.should == "SELECT (sql:SAMPLE (?s) AS ?s) WHERE { ?s ?p ?o . }"
      @query.select.where([:s, :p, :o]).group_concat(:s, '_').to_s.should == "SELECT (sql:GROUP_CONCAT (?s, '_' ) AS ?s) WHERE { ?s ?p ?o . }"
      @query.select.where([:s, :p, :o]).group_digest(:s, '_', 1000, 1).to_s.should == "SELECT (sql:GROUP_DIGEST (?s, '_', 1000, 1 ) AS ?s) WHERE { ?s ?p ?o . }"
    end

    it "should support aggregates in addition to SELECT variables" do
      @query.select(:s).where([:s, :p, :o]).group_digest(:o, '_', 1000, 1).to_s.should == "SELECT (sql:GROUP_DIGEST (?o, '_', 1000, 1 ) AS ?o) ?s WHERE { ?s ?p ?o . }"
    end
    
    it "should support ORDER BY" do
      @query.select.where([:s, :p, :o]).order_by(:o).to_s.should == "SELECT * WHERE { ?s ?p ?o . } ORDER BY ?o"
      @query.select.where([:s, :p, :o]).order_by('?o').to_s.should == "SELECT * WHERE { ?s ?p ?o . } ORDER BY ?o"
      # @query.select.where([:s, :p, :o]).order_by(:o => :asc).to_s.should == "SELECT * WHERE { ?s ?p ?o . } ORDER BY ?o ASC"
      @query.select.where([:s, :p, :o]).order_by('ASC(?o)').to_s.should == "SELECT * WHERE { ?s ?p ?o . } ORDER BY ASC(?o)"
      # @query.select.where([:s, :p, :o]).order_by(:o => :desc).to_s.should == "SELECT * WHERE { ?s ?p ?o . } ORDER BY ?o DESC"
      @query.select.where([:s, :p, :o]).order_by('DESC(?o)').to_s.should == "SELECT * WHERE { ?s ?p ?o . } ORDER BY DESC(?o)"
    end

    it "should support OFFSET" do
      @query.select.where([:s, :p, :o]).offset(100).to_s.should == "SELECT * WHERE { ?s ?p ?o . } OFFSET 100"
    end

    it "should support LIMIT" do
      @query.select.where([:s, :p, :o]).limit(10).to_s.should == "SELECT * WHERE { ?s ?p ?o . } LIMIT 10"
    end

    it "should support OFFSET with LIMIT" do
      @query.select.where([:s, :p, :o]).offset(100).limit(10).to_s.should == "SELECT * WHERE { ?s ?p ?o . } OFFSET 100 LIMIT 10"
      @query.select.where([:s, :p, :o]).slice(100, 10).to_s.should == "SELECT * WHERE { ?s ?p ?o . } OFFSET 100 LIMIT 10"
    end

    it "should support PREFIX" do
      prefixes = ["dc: <http://purl.org/dc/elements/1.1/>", "foaf: <http://xmlns.com/foaf/0.1/>"]
      @query.select.prefix(prefixes[0]).prefix(prefixes[1]).where([:s, :p, :o]).to_s.should ==
        "PREFIX #{prefixes[0]} PREFIX #{prefixes[1]} SELECT * WHERE { ?s ?p ?o . }"
    end

    it "constructs PREFIXes" do
      prefixes = RDF::Virtuoso::Prefixes.new dc: RDF::DC, foaf: RDF::FOAF
      @query.select.prefixes(prefixes).where([:s, :p, :o]).to_s.should ==
        "PREFIX dc: <#{RDF::DC}> PREFIX foaf: <#{RDF::FOAF}> SELECT * WHERE { ?s ?p ?o . }"
    end

    it "should support custom PREFIXes in hash array" do
      prefixes = RDF::Virtuoso::Prefixes.new foo: "http://foo.com/", bar: "http://bar.net"
      @query.select.prefixes(prefixes).where([:s, :p, :o]).to_s.should ==
        "PREFIX foo: <http://foo.com/> PREFIX bar: <http://bar.net> SELECT * WHERE { ?s ?p ?o . }"
    end
    
    it "should support OPTIONAL" do
      @query.select.where([:s, :p, :o]).optional([:s, RDF.type, :o], [:s, RDF::DC.abstract, :o]).to_s.should ==
        "SELECT * WHERE { ?s ?p ?o . OPTIONAL { ?s <#{RDF.type}> ?o . ?s <#{RDF::DC.abstract}> ?o . } }"
    end

    it "should support multiple OPTIONALs" do
      @query.select.where([:s, :p, :o]).optional([:s, RDF.type, :o]).optional([:s, RDF::DC.abstract, :o]).to_s.should ==
        "SELECT * WHERE { ?s ?p ?o . OPTIONAL { ?s <#{RDF.type}> ?o . } OPTIONAL { ?s <#{RDF::DC.abstract}> ?o . } }"
    end

    it "should support MINUS, also with an array pattern" do
      @query.select.where([:s, :p, :o]).minus([:s, RDF.type, :o], [:s, RDF::DC.abstract, :o]).to_s.should ==
        "SELECT * WHERE { ?s ?p ?o . MINUS { ?s <#{RDF.type}> ?o . ?s <#{RDF::DC.abstract}> ?o . } }"
    end

    it "should support multiple MINUSes" do
      @query.select.where([:s, :p, :o]).minus([:s, RDF.type, :o]).minus([:s, RDF::DC.abstract, :o]).to_s.should ==
        "SELECT * WHERE { ?s ?p ?o . MINUS { ?s <#{RDF.type}> ?o . } MINUS { ?s <#{RDF::DC.abstract}> ?o . } }"
    end
    
    it "should support UNION" do
      @query.select.where([:s, RDF::DC.abstract, :o]).union([:s, RDF.type, :o]).to_s.should ==
      "SELECT * WHERE { { ?s <#{RDF::DC.abstract}> ?o . } UNION { ?s <#{RDF.type}> ?o . } }"
    end

    it "should support FILTER" do
      @query.select.where([:s, RDF::DC.abstract, :o]).filter('lang(?text) != "nb"').to_s.should ==
      "SELECT * WHERE { ?s <#{RDF::DC.abstract}> ?o . FILTER(lang(?text) != \"nb\") }"
    end

    it "should support multiple FILTERs" do
      filters = ['lang(?text) != "nb"', 'regex(?uri, "^https")']
      @query.select.where([:s, RDF::DC.abstract, :o]).filters(filters).to_s.should ==
      "SELECT * WHERE { ?s <#{RDF::DC.abstract}> ?o . FILTER(lang(?text) != \"nb\") FILTER(regex(?uri, \"^https\")) }"
    end
    
  end

  context "when building DESCRIBE queries" do
    it "should support basic graph patterns" do
      @query.describe.where([:s, :p, :o]).to_s.should == "DESCRIBE * WHERE { ?s ?p ?o . }"
    end

    it "should support projection" do
      @query.describe(:s).where([:s, :p, :o]).to_s.should == "DESCRIBE ?s WHERE { ?s ?p ?o . }"
      @query.describe(:s, :p).where([:s, :p, :o]).to_s.should == "DESCRIBE ?s ?p WHERE { ?s ?p ?o . }"
      @query.describe(:s, :p, :o).where([:s, :p, :o]).to_s.should == "DESCRIBE ?s ?p ?o WHERE { ?s ?p ?o . }"
    end

    it "should support RDF::URI arguments" do
      uris = ['http://www.bbc.co.uk/programmes/b007stmh#programme', 'http://www.bbc.co.uk/programmes/b00lg2xb#programme']
      @query.describe(RDF::URI.new(uris[0]),RDF::URI.new(uris[1])).to_s.should ==
        "DESCRIBE <#{uris[0]}> <#{uris[1]}>"
    end
  end

  context "when building CONSTRUCT queries" do
    it "should support basic graph patterns" do
      @query.construct([:s, :p, :o]).where([:s, :p, :o]).to_s.should == "CONSTRUCT { ?s ?p ?o . } WHERE { ?s ?p ?o . }"
    end

    it "should support complex constructs" do
      @query.construct([:s, :p, :o], [:s, :q, RDF::Literal.new("new")]).where([:s, :p, :o], [:s, :q, "old"]).to_s.should == "CONSTRUCT { ?s ?p ?o . ?s ?q \"new\" . } WHERE { ?s ?p ?o . ?s ?q \"old\" . }"
    end    
          

  end
end
