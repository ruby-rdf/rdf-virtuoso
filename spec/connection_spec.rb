require_relative 'spec_helper'

describe RDF::Virtuoso::Connection do
  before(:each) do
    @url = RDF::URI("http://reviewer:secret@localhost:8890/sparql-auth")
    @conn = RDF::Virtuoso::Connection.new(@url)
    @graph = 'http://example.org/'
    @query = RDF::Virtuoso::Query
  end

  it "supports opening a connection" do
    @conn.should respond_to(:open)
    @conn.open?.should be_false
    @conn.open
    @conn.open?.should be_true
  end

  it "supports closing a connection manually" do
    @conn.should respond_to(:close)
    @conn.open?.should be_false
    @conn.open
    @conn.open?.should be_true
    @conn.close
    @conn.open?.should be_false
  end

  it "supports closing a connection automatically" do
    @conn.open?.should be_false
    @conn.open do
      @conn.open?.should be_true
    end
    @conn.open?.should be_false
  end

  it "supports HTTP GET requests" do
    @conn.should respond_to(:get)
  end

  it "performs HTTP GET requests" do
    query = @query.ask.where([:s, :p, :o]).to_s
    response = @conn.get(query)
    response.should be_a_kind_of(Net::HTTPSuccess)
    response.body.should == 'true'
  end

  it "supports HTTP POST requests" do
    @conn.should respond_to(:post)
  end

  it "performs HTTP POST requests" do
    query = @query.create(RDF::URI.new(@graph)).to_s
    response = @conn.post(query)
    response.should be_a_kind_of(Net::HTTPSuccess)
    #TODO: parse body to verify
    query = @query.drop(RDF::URI.new(@graph)).to_s
    response = @conn.post(query)
    response.should be_a_kind_of(Net::HTTPSuccess)
  end

  it "has a URI representation" do
    @conn.should respond_to(:to_uri)
    @conn.to_uri.should be_a_uri
    @conn.to_uri.to_s.should == RDF::URI(@url.to_hash).to_s
  end

  it "has a string representation" do
    @conn.should respond_to(:to_s)
    @conn.to_s.should == RDF::URI(@url.to_hash).to_s
  end

end
