require File.join(File.dirname(__FILE__), 'spec_helper')

describe RDF::Virtuoso::Query do
  subject {RDF::Virtuoso::Query}

  context "when building queries" do
    it "should support ASK queries" do
      is_expected.to respond_to(:ask)
    end

    it "should support SELECT queries" do
      is_expected.to respond_to(:select)
    end

    it "should support DESCRIBE queries" do
      is_expected.to respond_to(:describe)
    end

    it "should support CONSTRUCT queries" do
      is_expected.to respond_to(:construct)
    end

    it "should support INSERT DATA queries" do
      is_expected.to respond_to(:insert_data)
    end

    it "should support INSERT WHERE queries" do
      is_expected.to respond_to(:insert)
    end
    
    it "should support DELETE DATA queries" do
      is_expected.to respond_to(:delete_data)
    end

    it "should support DELETE WHERE queries" do
      is_expected.to respond_to(:delete)
    end

    it "should support CREATE GRAPH queries" do
      is_expected.to respond_to(:create)
    end

  end

  context "when building update queries" do
    let(:graph) {"http://example.org/"}
    let(:uri) {RDF::Vocabulary.new "http://example.org/"}

    # TODO add support for advanced inserts (moving copying between different graphs)
    it "should support INSERT DATA queries" do
      expect(subject.insert_data([uri.ola, uri.type, uri.something]).graph(RDF::URI.new(graph)).to_s).to eql "INSERT DATA INTO GRAPH <#{graph}> { <#{graph}ola> <#{graph}type> <#{graph}something> . }"
      expect(subject.insert_data([uri.ola, uri.name, "two words"]).graph(RDF::URI.new(graph)).to_s).to eql "INSERT DATA INTO GRAPH <#{graph}> { <#{graph}ola> <#{graph}name> \"two words\" . }"
    end

    it "should support INSERT DATA queries with arrays" do
      expect(subject.insert_data([uri.ola, uri.type, uri.something],[uri.ola, uri.type, uri.somethingElse]).graph(RDF::URI.new(graph)).to_s).to eql "INSERT DATA INTO GRAPH <#{graph}> { <#{graph}ola> <#{graph}type> <#{graph}something> . <#{graph}ola> <#{graph}type> <#{graph}somethingElse> . }"
    end
    
    it "should support INSERT DATA queries with RDF::Statements" do
      statements = [RDF::Statement.new(RDF::URI('http://test'), RDF.type, RDF::URI('http://type')), RDF::Statement.new(RDF::URI('http://test'), RDF.type, RDF::URI('http://type2'))]
      expect(subject.insert_data(statements).graph(RDF::URI.new(graph)).to_s).to eql "INSERT DATA INTO GRAPH <#{graph}> { <http://test> <#{RDF.type}> <http://type> .\n <http://test> <#{RDF.type}> <http://type2> .\n }"
    end
    
    it "should support INSERT WHERE queries with symbols and patterns" do
      expect(subject.insert([:s, :p, :o]).graph(RDF::URI.new(graph)).where([:s, :p, :o]).to_s).to eql "INSERT INTO GRAPH <#{graph}> { ?s ?p ?o . } WHERE { ?s ?p ?o . }"
      expect(subject.insert([:s, uri.newtype, :o]).graph(RDF::URI.new(graph)).where([:s, uri.type, :o]).to_s).to eql "INSERT INTO GRAPH <#{graph}> { ?s <#{graph}newtype> ?o . } WHERE { ?s <#{graph}type> ?o . }"
    end

    it "should support DELETE DATA queries" do
      expect(subject.delete_data([uri.ola, uri.type, uri.something]).graph(RDF::URI.new(graph)).to_s).to eql "DELETE DATA FROM <#{graph}> { <#{graph}ola> <#{graph}type> <#{graph}something> . }"  
      expect(subject.delete_data([uri.ola, uri.name, RDF::Literal.new("myname")]).graph(RDF::URI.new(graph)).to_s).to eql "DELETE DATA FROM <#{graph}> { <#{graph}ola> <#{graph}name> \"myname\" . }"  
    end

    it "should support DELETE DATA queries with arrays" do
      expect(subject.delete_data([uri.ola, uri.type, uri.something],[uri.ola, uri.type, uri.somethingElse]).graph(RDF::URI.new(graph)).to_s).to eql "DELETE DATA FROM <#{graph}> { <#{graph}ola> <#{graph}type> <#{graph}something> . <#{graph}ola> <#{graph}type> <#{graph}somethingElse> . }"
    end
    
    it "should support DELETE DATA queries with RDF::Statements" do
      statements = [RDF::Statement.new(RDF::URI('http://test'), RDF.type, RDF::URI('http://type')), RDF::Statement.new(RDF::URI('http://test'), RDF.type, RDF::URI('http://type2'))]
      expect(subject.delete_data(statements).graph(RDF::URI.new(graph)).to_s).to eql "DELETE DATA FROM <#{graph}> { <http://test> <#{RDF.type}> <http://type> .\n <http://test> <#{RDF.type}> <http://type2> .\n }"
    end

    it "should support DELETE DATA queries with appendable objects" do
      statements = []
      statements << RDF::Statement.new(RDF::URI('http://test'), RDF.type, RDF::URI('http://type'))
      statements << RDF::Statement.new(RDF::URI('http://test'), RDF.type, RDF::URI('http://type2'))
      expect(subject.delete_data(statements).graph(RDF::URI.new(graph)).to_s).to eql "DELETE DATA FROM <#{graph}> { <http://test> <#{RDF.type}> <http://type> .\n <http://test> <#{RDF.type}> <http://type2> .\n }"
    end
        
    it "should support DELETE WHERE queries with symbols and patterns" do
      expect(subject.delete([:s, :p, :o]).graph(RDF::URI.new(graph)).where([:s, :p, :o]).to_s).to eql "DELETE FROM <#{graph}> { ?s ?p ?o . } WHERE { ?s ?p ?o . }"
      expect(subject.delete([:s, uri.newtype, :o]).graph(RDF::URI.new(graph)).where([:s, uri.newtype, :o]).to_s).to eql "DELETE FROM <#{graph}> { ?s <#{graph}newtype> ?o . } WHERE { ?s <#{graph}newtype> ?o . }"
    end

    it "should support CREATE GRAPH queries" do
      expect(subject.create(RDF::URI.new(graph)).to_s).to eql "CREATE GRAPH <#{graph}>"
      expect(subject.create(RDF::URI.new(graph), silent: true).to_s).to eql "CREATE SILENT GRAPH <#{graph}>"
    end

    it "should support DROP GRAPH queries" do
      expect(subject.drop(RDF::URI.new(graph)).to_s).to eql "DROP GRAPH <#{graph}>"
      expect(subject.drop(RDF::URI.new(graph), silent: true).to_s).to eql "DROP SILENT GRAPH <#{graph}>"

    end

  end

  context "when building ASK queries" do
    it "should support basic graph patterns" do
      expect(subject.ask.where([:s, :p, :o]).to_s).to eql "ASK WHERE { ?s ?p ?o . }"
      expect(subject.ask.whether([:s, :p, :o]).to_s).to eql "ASK WHERE { ?s ?p ?o . }"
    end
  end

  context "when building SELECT queries" do
    it "should support basic graph patterns" do
      expect(subject.select.where([:s, :p, :o]).to_s).to eql "SELECT * WHERE { ?s ?p ?o . }"
    end

    it "should support projection" do
      expect(subject.select(:s).where([:s, :p, :o]).to_s).to eql "SELECT ?s WHERE { ?s ?p ?o . }"
      expect(subject.select(:s, :p).where([:s, :p, :o]).to_s).to eql "SELECT ?s ?p WHERE { ?s ?p ?o . }"
      expect(subject.select(:s, :p, :o).where([:s, :p, :o]).to_s).to eql "SELECT ?s ?p ?o WHERE { ?s ?p ?o . }"
    end

    it "should support SELECT FROM" do
      graph = RDF::URI("http://example.org/")
      expect(subject.select(:s).where([:s, :p, :o]).from(graph).to_s).to eql "SELECT ?s FROM <#{graph}> WHERE { ?s ?p ?o . }"
    end

    it "should support SELECT FROM and FROM NAMED" do
      graph1 = RDF::URI("a")
      graph2 = RDF::URI("b")
      expect(subject.select(:s).where([:s, :p, :o, graph_name: graph2]).from(graph1).from_named(graph2).to_s).to eql(
        "SELECT ?s FROM <#{graph1}> FROM NAMED <#{graph2}> WHERE { GRAPH <#{graph2}> { ?s ?p ?o . } }"
      )
    end

    it "should support one SELECT FROM and multiple FROM NAMED" do
      graph1 = RDF::URI("a")
      graph2 = RDF::URI("b")
      graph3 = RDF::URI("c")
      expect(subject.select(:s).where([:s, :p, :o, graph_name: graph2], [:s, :p, :o, graph_name: graph3]).from(graph1).from_named(graph2).from_named(graph3).to_s).to eql(
        "SELECT ?s FROM <#{graph1}> FROM NAMED <#{graph2}> FROM NAMED <#{graph3}> WHERE { GRAPH <#{graph2}> { ?s ?p ?o . } GRAPH <#{graph3}> { ?s ?p ?o . } }"
      )
    end

    it "should support SELECT with complex WHERE patterns" do
      expect(subject.select.where(
      [:s, :p, :o],
      [:s, RDF.type, RDF::Vocab::DC.BibliographicResource]
      ).to_s).to eql(
        "SELECT * WHERE { ?s ?p ?o . ?s <#{RDF.type}> <#{RDF::Vocab::DC.BibliographicResource}> . }"
      )
    end

    it "should support SELECT WHERE patterns from different GRAPH names" do
      graph1 = RDF::URI("http://example1.org/")
      graph2 = RDF::URI("http://example2.org/")
      expect(subject.select.where([:s, :p, :o, graph_name: graph1],[:s, RDF.type, RDF::Vocab::DC.BibliographicResource, graph_name: graph2]).to_s).to eql(
        "SELECT * WHERE { GRAPH <#{graph1}> { ?s ?p ?o . } GRAPH <#{graph2}> { ?s <#{RDF.type}> <#{RDF::Vocab::DC.BibliographicResource}> . } }"
      )
    end

    it "should support string objects in SPARQL queries" do
      expect(subject.select.where([:s, :p, "dummyobject"]).to_s).to eql "SELECT * WHERE { ?s ?p \"dummyobject\" . }"
    end

    #it "should support raw string SPARQL queries" do
    #  q = "SELECT * WHERE { ?s <#{RDF.type}> ?o . }"
    #  expect(subject.query(q)).to eql "SELECT * WHERE { ?s <#{RDF.type}> ?o . }"
    #end

    it "should support FROM" do
      uri = "http://example.org/dft.ttl"
      expect(subject.select.from(RDF::URI.new(uri)).where([:s, :p, :o]).to_s).to eql(
        "SELECT * FROM <#{uri}> WHERE { ?s ?p ?o . }"
      )
    end

    it "should support DISTINCT" do
      expect(subject.select(:s, distinct: true).where([:s, :p, :o]).to_s).to eql "SELECT DISTINCT ?s WHERE { ?s ?p ?o . }"
      expect(subject.select(:s).distinct.where([:s, :p, :o]).to_s).to eql "SELECT DISTINCT ?s WHERE { ?s ?p ?o . }"
    end

    it "should support REDUCED" do
      expect(subject.select(:s, reduced: true).where([:s, :p, :o]).to_s).to eql "SELECT REDUCED ?s WHERE { ?s ?p ?o . }"
      expect(subject.select(:s).reduced.where([:s, :p, :o]).to_s).to eql "SELECT REDUCED ?s WHERE { ?s ?p ?o . }"
    end

    it "should support aggregate COUNT" do
      expect(subject.select.where([:s, :p, :o]).count(:s).to_s).to eql "SELECT (COUNT (?s) AS ?s) WHERE { ?s ?p ?o . }"
      expect(subject.select.count(:s).where([:s, :p, :o]).to_s).to eql "SELECT (COUNT (?s) AS ?s) WHERE { ?s ?p ?o . }"
    end

    it "should support aggregates SUM, MIN, MAX, AVG, SAMPLE, GROUP_CONCAT, GROUP_DIGEST" do
      expect(subject.select.where([:s, :p, :o]).sum(:s).to_s).to eql "SELECT (SUM (?s) AS ?s) WHERE { ?s ?p ?o . }"
      expect(subject.select.where([:s, :p, :o]).min(:s).to_s).to eql "SELECT (MIN (?s) AS ?s) WHERE { ?s ?p ?o . }"
      expect(subject.select.where([:s, :p, :o]).max(:s).to_s).to eql "SELECT (MAX (?s) AS ?s) WHERE { ?s ?p ?o . }"
      expect(subject.select.where([:s, :p, :o]).avg(:s).to_s).to eql "SELECT (AVG (?s) AS ?s) WHERE { ?s ?p ?o . }"
      expect(subject.select.where([:s, :p, :o]).sample(:s).to_s).to eql "SELECT (sql:SAMPLE (?s) AS ?s) WHERE { ?s ?p ?o . }"
      expect(subject.select.where([:s, :p, :o]).group_concat(:s, '_').to_s).to eql "SELECT (sql:GROUP_CONCAT (?s, '_' ) AS ?s) WHERE { ?s ?p ?o . }"
      expect(subject.select.where([:s, :p, :o]).group_digest(:s, '_', 1000, 1).to_s).to eql "SELECT (sql:GROUP_DIGEST (?s, '_', 1000, 1 ) AS ?s) WHERE { ?s ?p ?o . }"
    end

    it "should support multiple instances of SAMPLE" do
      expect(subject.select.where([:s, :p, :o]).sample(:s).sample(:p).to_s).to eql "SELECT (sql:SAMPLE (?s) AS ?s) (sql:SAMPLE (?p) AS ?p) WHERE { ?s ?p ?o . }"
    end

    it "should support multiple instances of MIN/MAX/AVG/SUM" do
      expect(subject.select.where([:s, :p, :o]).min(:s).min(:p).to_s).to eql "SELECT (MIN (?s) AS ?s) (MIN (?p) AS ?p) WHERE { ?s ?p ?o . }"
      expect(subject.select.where([:s, :p, :o]).max(:s).max(:p).to_s).to eql "SELECT (MAX (?s) AS ?s) (MAX (?p) AS ?p) WHERE { ?s ?p ?o . }"
      expect(subject.select.where([:s, :p, :o]).avg(:s).avg(:p).to_s).to eql "SELECT (AVG (?s) AS ?s) (AVG (?p) AS ?p) WHERE { ?s ?p ?o . }"      
      expect(subject.select.where([:s, :p, :o]).sum(:s).sum(:p).to_s).to eql "SELECT (SUM (?s) AS ?s) (SUM (?p) AS ?p) WHERE { ?s ?p ?o . }"      
    end
    
    it "should support multiple instances of GROUP_CONCAT" do
      expect(subject.select.where([:s, :p, :o]).group_concat(:s, '_').group_concat(:p, '-').to_s).to eql "SELECT (sql:GROUP_CONCAT (?s, '_' ) AS ?s) (sql:GROUP_CONCAT (?p, '-' ) AS ?p) WHERE { ?s ?p ?o . }"
    end

    it "should support multiple instances of GROUP_DIGEST" do
      expect(subject.select.where([:s, :p, :o]).group_digest(:s, '_', 1000, 1).group_digest(:p, '-', 1000, 1).to_s).to eql "SELECT (sql:GROUP_DIGEST (?s, '_', 1000, 1 ) AS ?s) (sql:GROUP_DIGEST (?p, '-', 1000, 1 ) AS ?p) WHERE { ?s ?p ?o . }"
    end
            
    it "should support aggregates in addition to SELECT variables" do
      expect(subject.select(:s).where([:s, :p, :o]).group_digest(:o, '_', 1000, 1).to_s).to eql "SELECT (sql:GROUP_DIGEST (?o, '_', 1000, 1 ) AS ?o) ?s WHERE { ?s ?p ?o . }"
    end

    it "should support multiple instances of aggregates AND select variables" do
      expect(subject.select(:s).where([:s, :p, :o]).sample(:p).sample(:o).to_s).to eql "SELECT (sql:SAMPLE (?p) AS ?p) (sql:SAMPLE (?o) AS ?o) ?s WHERE { ?s ?p ?o . }"
    end
        
    it "should support ORDER BY" do
      expect(subject.select.where([:s, :p, :o]).order_by(:o).to_s).to eql "SELECT * WHERE { ?s ?p ?o . } ORDER BY ?o"
      expect(subject.select.where([:s, :p, :o]).order_by('?o').to_s).to eql "SELECT * WHERE { ?s ?p ?o . } ORDER BY ?o"
      # expect(subject.select.where([:s, :p, :o]).order_by(o: :asc).to_s).to eql "SELECT * WHERE { ?s ?p ?o . } ORDER BY ?o ASC"
      expect(subject.select.where([:s, :p, :o]).order_by('ASC(?o)').to_s).to eql "SELECT * WHERE { ?s ?p ?o . } ORDER BY ASC(?o)"
      # subject.select.where([:s, :p, :o]).order_by(o: :desc.to_s).to eql "SELECT * WHERE { ?s ?p ?o . } ORDER BY ?o DESC"
      expect(subject.select.where([:s, :p, :o]).order_by('DESC(?o)').to_s).to eql "SELECT * WHERE { ?s ?p ?o . } ORDER BY DESC(?o)"
    end

    it "should support OFFSET" do
      expect(subject.select.where([:s, :p, :o]).offset(100).to_s).to eql "SELECT * WHERE { ?s ?p ?o . } OFFSET 100"
    end

    it "should support LIMIT" do
      expect(subject.select.where([:s, :p, :o]).limit(10).to_s).to eql "SELECT * WHERE { ?s ?p ?o . } LIMIT 10"
    end

    it "should support OFFSET with LIMIT" do
      expect(subject.select.where([:s, :p, :o]).offset(100).limit(10).to_s).to eql "SELECT * WHERE { ?s ?p ?o . } OFFSET 100 LIMIT 10"
      expect(subject.select.where([:s, :p, :o]).slice(100, 10).to_s).to eql "SELECT * WHERE { ?s ?p ?o . } OFFSET 100 LIMIT 10"
    end

#  DEPRECATED - USE RDF::Vocabulary instead
=begin
    it "should support PREFIX" do
      prefixes = ["dc: <http://purl.org/dc/elements/1.1/>", "foaf: <http://xmlns.com/foaf/0.1/>"]
      subject.select.prefix(prefixes[0]).prefix(prefixes[1]).where([:s, :p, :o].to_s).to eql
        "PREFIX #{prefixes[0]} PREFIX #{prefixes[1]} SELECT * WHERE { ?s ?p ?o . }"
    end

    it "constructs PREFIXes" do
      prefixes = RDF::Virtuoso::Prefixes.new dc: RDF::Vocab::DC, foaf: RDF::FOAF
      subject.select.prefixes(prefixes).where([:s, :p, :o].to_s).to eql
        "PREFIX dc: <#{RDF::Vocab::DC}> PREFIX foaf: <#{RDF::FOAF}> SELECT * WHERE { ?s ?p ?o . }"
    end

    it "should support custom PREFIXes in hash array" do
      prefixes = RDF::Virtuoso::Prefixes.new foo: "http://foo.com/", bar: "http://bar.net"
      subject.select.prefixes(prefixes).where([:s, :p, :o].to_s).to eql
        "PREFIX foo: <http://foo.com/> PREFIX bar: <http://bar.net> SELECT * WHERE { ?s ?p ?o . }"
    end

    it "should support accessing custom PREFIXes in SELECT" do
      prefixes = RDF::Virtuoso::Prefixes.new foo: "http://foo.com/"
      subject.select.where(['foo:bar', :p, :o]).prefixes(prefixes.to_s).to eql
        "PREFIX foo: <http://foo.com/bar> SELECT * WHERE { ?s ?p ?o . }"
    end
=end  

    it "should support using custom RDF::Vocabulary prefixes" do
      BIBO = RDF::Vocabulary.new("http://purl.org/ontology/bibo/")
      expect(subject.select.where([:s, :p, BIBO.Document]).to_s).to eql(
        "SELECT * WHERE { ?s ?p <http://purl.org/ontology/bibo/Document> . }"
      )
    end
    
    it "should support OPTIONAL" do
      expect(subject.select.where([:s, :p, :o]).optional([:s, RDF.type, :o], [:s, RDF::Vocab::DC.abstract, :o]).to_s).to eql(
        "SELECT * WHERE { ?s ?p ?o . OPTIONAL { ?s <#{RDF.type}> ?o . ?s <#{RDF::Vocab::DC.abstract}> ?o . } }"
      )
    end

    it "should support OPTIONAL with GRAPH names" do
      graph1 = RDF::URI("http://example1.org/")
      graph2 = RDF::URI("http://example2.org/")
      expect(subject.select.where([:s, :p, :o, graph_name: graph1]).optional([:s, RDF.type, RDF::Vocab::DC.BibliographicResource, graph_name: graph2]).to_s).to eql(
        "SELECT * WHERE { GRAPH <#{graph1}> { ?s ?p ?o . } OPTIONAL { GRAPH <#{graph2}> { ?s <#{RDF.type}> <#{RDF::Vocab::DC.BibliographicResource}> . } } }"
      )
    end
    
    it "should support multiple OPTIONALs" do
      expect(subject.select.where([:s, :p, :o]).optional([:s, RDF.type, :o]).optional([:s, RDF::Vocab::DC.abstract, :o]).to_s).to eql(
        "SELECT * WHERE { ?s ?p ?o . OPTIONAL { ?s <#{RDF.type}> ?o . } OPTIONAL { ?s <#{RDF::Vocab::DC.abstract}> ?o . } }"
      )
    end

    it "should support MINUS, also with an array pattern" do
      expect(subject.select.where([:s, :p, :o]).minus([:s, RDF.type, :o], [:s, RDF::Vocab::DC.abstract, :o]).to_s).to eql(
        "SELECT * WHERE { ?s ?p ?o . MINUS { ?s <#{RDF.type}> ?o . ?s <#{RDF::Vocab::DC.abstract}> ?o . } }"
      )
    end

    it "should support multiple MINUSes" do
      expect(subject.select.where([:s, :p, :o]).minus([:s, RDF.type, :o]).minus([:s, RDF::Vocab::DC.abstract, :o]).to_s).to eql(
        "SELECT * WHERE { ?s ?p ?o . MINUS { ?s <#{RDF.type}> ?o . } MINUS { ?s <#{RDF::Vocab::DC.abstract}> ?o . } }"
      )
    end

    it "should support MINUS with a GRAPH name" do
      graph1 = RDF::URI("http://example1.org/")
      expect(subject.select.where([:s, :p, :o]).minus([:s, RDF.type, :o, graph_name: graph1]).to_s).to eql(
        "SELECT * WHERE { ?s ?p ?o . MINUS { GRAPH <#{graph1}> { ?s <#{RDF.type}> ?o . } } }"
      )
    end
        
    it "should support UNION" do
      expect(subject.select.where([:s, RDF::Vocab::DC.abstract, :o]).union([:s, RDF.type, :o]).to_s).to eql(
        "SELECT * WHERE { { ?s <#{RDF::Vocab::DC.abstract}> ?o . } UNION { ?s <#{RDF.type}> ?o . } }"
      )
    end

    it "should support FILTER" do
      expect(subject.select.where([:s, RDF::Vocab::DC.abstract, :o]).filter('lang(?text) != "nb"').to_s).to eql(
        "SELECT * WHERE { ?s <#{RDF::Vocab::DC.abstract}> ?o . FILTER(lang(?text) != \"nb\") }"
      )
    end

    it "should support multiple FILTERs" do
      filters = ['lang(?text) != "nb"', 'regex(?uri, "^https")']
      expect(subject.select.where([:s, RDF::Vocab::DC.abstract, :o]).filters(filters).to_s).to eql(
        "SELECT * WHERE { ?s <#{RDF::Vocab::DC.abstract}> ?o . FILTER(lang(?text) != \"nb\") FILTER(regex(?uri, \"^https\")) }"
      )
    end

    it "should support DEFINE headers in queries" do
      define = 'sql:select-option "ORDER"'
      expect(subject.select.where([:s, RDF::Vocab::DC.abstract, :o]).define(define).to_s).to eql(
        "DEFINE #{define} SELECT * WHERE { ?s <#{RDF::Vocab::DC.abstract}> ?o . }"
      )
    end

    it "should support grouping graph patterns within brackets" do
      expect(subject.select.where.group([:s, :p, :o],[:s2, :p2, :o2]).
      where([:s3, :p3, :o3]).to_s).to eql(
        "SELECT * WHERE { { ?s ?p ?o . ?s2 ?p2 ?o2 . } ?s3 ?p3 ?o3 . }"
      )
    end

    it "should support grouping with several graph statements" do
      expect(subject.select.where.graph2(RDF::URI.new("a")).group([:s, :p, :o],[:s2, :p2, :o2]).
      where.graph2(RDF::URI.new("b")).group([:s3, :p3, :o3]).to_s).to eql(
        "SELECT * WHERE { GRAPH <a> { ?s ?p ?o . ?s2 ?p2 ?o2 . } GRAPH <b> { ?s3 ?p3 ?o3 . } }"
      )
    end

  end

  context "when building DESCRIBE queries" do
    it "should support basic graph patterns" do
      expect(subject.describe.where([:s, :p, :o]).to_s).to eql "DESCRIBE * WHERE { ?s ?p ?o . }"
    end

    it "should support projection" do
      expect(subject.describe(:s).where([:s, :p, :o]).to_s).to eql "DESCRIBE ?s WHERE { ?s ?p ?o . }"
      expect(subject.describe(:s, :p).where([:s, :p, :o]).to_s).to eql "DESCRIBE ?s ?p WHERE { ?s ?p ?o . }"
      expect(subject.describe(:s, :p, :o).where([:s, :p, :o]).to_s).to eql "DESCRIBE ?s ?p ?o WHERE { ?s ?p ?o . }"
    end

    it "should support RDF::URI arguments" do
      uris = ['http://www.bbc.co.uk/programmes/b007stmh#programme', 'http://www.bbc.co.uk/programmes/b00lg2xb#programme']
      expect(subject.describe(RDF::URI.new(uris[0]),RDF::URI.new(uris[1])).to_s).to eql(
        "DESCRIBE <#{uris[0]}> <#{uris[1]}>"
      )
    end
  end

  context "when building CONSTRUCT queries" do
    it "should support basic graph patterns" do
      expect(subject.construct([:s, :p, :o]).where([:s, :p, :o]).to_s).to eql "CONSTRUCT { ?s ?p ?o . } WHERE { ?s ?p ?o . }"
    end

    it "should support complex constructs" do
      expect(subject.construct([:s, :p, :o], [:s, :q, RDF::Literal.new("new")]).where([:s, :p, :o], [:s, :q, "old"]).to_s).to eql "CONSTRUCT { ?s ?p ?o . ?s ?q \"new\" . } WHERE { ?s ?p ?o . ?s ?q \"old\" . }"
    end    
          

  end
end
