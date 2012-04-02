module RDF::Virtuoso

  class Prefixes

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
