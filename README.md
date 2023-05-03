# rdf-virtuoso: Ruby Virtuoso adapter for RDF.rb

The intent of this class is to act as an abstraction for clients wishing to connect and manipulate linked data stored in a Virtuoso Quad store.

[![Gem Version](https://badge.fury.io/rb/rdf-virtuoso.svg)](https://badge.fury.io/rb/rdf-virtuoso)
[![Build Status](https://github.com/ruby-rdf/rdf-virtuoso/workflows/CI/badge.svg?branch=develop)](https://github.com/ruby-rdf/rdf-virtuoso/actions?query=workflow%3ACI)
[![Gitter chat](https://badges.gitter.im/ruby-rdf/rdf.png)](https://gitter.im/ruby-rdf/rdf)

## How?
`RDF::Virtuoso::Repository` subclasses `RDF::Repository` built on [RDF.rb][] and is the main connection class built on top of APISmith to establish the read and write methods to a Virtuoso store SPARQL endpoint.
`RDF::Virtuoso::Query` subclasses `RDF::Query` and adds SPARQL 1.1. update methods (insert, delete, aggregates, etc.).

For examples on use, please read:
     ./spec/repository_spec.rb 
and 
     ./spec/query_spec.rb 

### A simple example

This example assumes you have a local installation of Virtoso running at standard port 8890

#### Setup Repository connection connection with auth

    uri        = "http://localhost:8890/sparql"
    update_uri = "http://localhost:8890/sparql-auth"
    repo       = RDF::Virtuoso::Repository.new(uri, 
                    update_uri: update_uri, 
                    username: 'admin', 
                    password: 'secret', 
                    auth_method: 'digest')

:auth_method can be 'digest' or 'basic'. a repository connection without auth requires only uri

#### INSERT WHERE query example

    QUERY = RDF::Virtuoso::Query
    graph = RDF::URI.new("http://test.com")
    subject = RDF::URI.new("http://subject")

    query = QUERY.insert([subject, :p, "object"]).graph(graph).where([subject, :p, :o])
    result = repo.insert(query)

#### A count query example

New prefixes can either extend the RDF::Vocabulary class (best if you want to model yourself:

    module RDF
      class FOO < RDF::Vocabulary("http://purl.org/ontology/foo/");end
      class BAR < RDF::Vocabulary("http://bar.net#");end
    end

it can then be easily accessed by RDF superclass, eg. 

    RDF::FOO.Document
    => #<RDF::URI:0x4d273ec(http://purl.org/ontology/foo/Document)> 
    RDF::BAR.telescope
    => #<RDF::URI:0x4d294ee(http://bar.net#telescope)> 

or you can dynamically add RDF::Vocabulary objects

    foo = RDF::Vocabulary.new("http://purl.org/ontology/foo/")

    QUERY  = RDF::Virtuoso::Query
    graph  = RDF::URI.new("http://test.com")

    query  = QUERY.select.where([:s, foo.bar, :o]).count(:s).graph(graph)
    result = repo.select(query)
    
Results will be an array of RDF::Query::Solution that can be accessed by bindings or iterated

    count = result.first[:count].to_i

## Contributing

This repository uses [Git Flow](https://github.com/nvie/gitflow) to mange development and release activity. All submissions _must_ be on a feature branch based on the _develop_ branch to ease staging and integration.

* Do your best to adhere to the existing coding conventions and idioms.
* Don't use hard tabs, and don't leave trailing whitespace on any line.
  Before committing, run `git diff --check` to make sure of this.
* Do document every method you add using [YARD][] annotations. Read the
  [tutorial][YARD-GS] or just look at the existing code for examples.
* Don't touch the `.gemspec` or `VERSION` files. If you need to change them,
  do so on your private branch only.
* Do note that in order for us to merge any non-trivial changes (as a rule
  of thumb, additions larger than about 15 lines of code), we need an
  explicit [public domain dedication][PDD] on record from you,
  which you will be asked to agree to on the first commit to a repo within the organization.
  Note that the agreement applies to all repos in the [Ruby RDF](https://github.com/ruby-rdf/) organization.

## License

This is free and unencumbered public domain software. For more information,
see <https://unlicense.org/> or the accompanying {file:LICENSE} file.

[PDD]:              https://unlicense.org/#unlicensing-contributions
[YARD]:             https://yardoc.org/
[YARD-GS]:          https://rubydoc.info/docs/yard/file/docs/GettingStarted.md
[RDF.rb]:       https://ruby-rdf.github.io/rdf
