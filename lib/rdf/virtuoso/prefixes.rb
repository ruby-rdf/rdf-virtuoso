module RDF::Virtuoso
  require 'uri'

  class UnProcessable; end
  class Prefixes

    PREFIXES = {
      dc:    'http://purl.org/dc/terms/',
      bibo:  'http://purl.org/ontology/bibo/',
      fabio: 'http://purl.org/spar/fabio/',
      rev:   'http://purl.org/stuff/rev#',
      foaf:  'http://xmlns.com/foaf/0.1/',
      lang:  'http://lexvo.org/id/iso639-3/'
    }

    class << self
      def parse(uri_or_array)
        prefixes = case uri_or_array
                   when String then [uri_or_array]
                   when Array  then uri_or_array
                   else return UnProcessable.new
                   end
        result = Set.new
        prefixes.each do |prefix|
          uri = URI(prefix)
          str = ""
          str << uri.host.split('.')[-2]
          /^(?<iri>.*[\/|#]).+$/ =~ uri.to_s
          str << ": <%s>" % iri
          result << str
        end
        result.to_a
      end
    end

    def initialize(prefixes={})
      @prefixes = prefixes
    end

    def to_a
      ary = []
      @prefixes.each_pair do |key, value|
        ary << "#{key}: <#{value}>"
      end
      ary
    end

    def to_s
      @prefixes.inspect
    end

  end

end
