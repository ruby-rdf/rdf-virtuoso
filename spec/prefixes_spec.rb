require_relative '../lib/rdf/virtuoso/prefixes'

describe RDF::Virtuoso::Prefixes do
  subject { RDF::Virtuoso::Prefixes.new(foo: 'bar', baz: 'quux') }

  it "takes a hash when initialized" do
    subject.should be_a RDF::Virtuoso::Prefixes
  end

  it "responds to to_a" do
    subject.should respond_to :to_a
  end

  it "returns a nice array" do
    subject.to_a.should == ["foo: <bar>", "baz: <quux>"]
  end

  it "presents itself nicely" do
    subject.to_s.should == "{:foo=>\"bar\", :baz=>\"quux\"}"
  end

  context "when creating prefixes" do
    let(:uris) { %w[http://example.org/foo http://hash.org#bar] }

    it "creates prefixes from uris" do
      RDF::Virtuoso::Prefixes.parse(uris).should == ["example: <http://example.org/>", "hash: <http://hash.org#>"]
    end

    it "only creates unique prefixes from uris" do
      uris << 'http://example.org/bar'
      RDF::Virtuoso::Prefixes.parse(uris).should == ["example: <http://example.org/>", "hash: <http://hash.org#>"]
    end

    it "returns an error object if a disallowed param is sent" do
      RDF::Virtuoso::Prefixes.parse({}).should be_a RDF::Virtuoso::UnProcessable
    end

  end
end
