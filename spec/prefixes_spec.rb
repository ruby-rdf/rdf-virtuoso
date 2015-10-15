require File.join(File.dirname(__FILE__), 'spec_helper')
require_relative '../lib/rdf/virtuoso/prefixes'

describe RDF::Virtuoso::Prefixes do
  subject { RDF::Virtuoso::Prefixes.new(foo: 'bar', baz: 'quux') }

  it "takes a hash when initialized" do
    is_expected.to be_a RDF::Virtuoso::Prefixes
  end

  it "responds to to_a" do
    is_expected.to respond_to :to_a
  end

  it "returns a nice array" do
    expect(subject.to_a).to include("foo: <bar>", "baz: <quux>")
  end

  it "presents itself nicely" do
    expect(subject.to_s).to eql "{:foo=>\"bar\", :baz=>\"quux\"}"
  end

  context "when creating prefixes" do
    let(:uris) { [RDF::Vocab::DC.title.to_s, "http://example.org/foo/bar", "http://hash.org/foo#bar"] }

    it "creates prefixes from uris" do
      expect(RDF::Virtuoso::Prefixes.parse(uris)).to include(
        "purl: <http://purl.org/dc/terms/>", 
        "example: <http://example.org/foo/>", 
        "hash: <http://hash.org/foo#>"
      )
    end

    it "only creates unique prefixes from uris" do
      uris << 'http://example.org/foo/baz'
      expect(RDF::Virtuoso::Prefixes.parse(uris)).to include(
        "purl: <http://purl.org/dc/terms/>", 
        "example: <http://example.org/foo/>", 
        "hash: <http://hash.org/foo#>"
      )
    end

    it "returns an error object if a disallowed param is sent" do
      expect(RDF::Virtuoso::Prefixes.parse({})).to be_a RDF::Virtuoso::UnProcessable
    end

  end
end
