require 'rdf'

module RDF
  module Virtuoso
    autoload :Repository,  'rdf/virtuoso/repository'
    autoload :Query,       'rdf/virtuoso/query'
    autoload :Prefixes,    'rdf/virtuoso/prefixes'
    autoload :Parser,      'rdf/virtuoso/parser'
    autoload :VERSION,     'rdf/virtuoso/version'
  end
end
