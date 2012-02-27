require 'rdf'
require 'enumerator'
require 'sparql/client'

module RDF
  module Virtuoso
    class Repository < ::SPARQL::Client::Repository
      def initialize(endpoint, options = {})
        super(endpoint, options)
      end
    end
  end
end
