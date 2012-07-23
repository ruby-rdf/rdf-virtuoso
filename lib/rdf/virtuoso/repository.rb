require 'rdf'
require 'enumerator'

module RDF::Virtuoso

  class Repository < RDF::Repository

    attr_reader :url
    attr_reader :options
    attr_reader :connection
    attr_reader :client

    alias_method :uri, :url

    def initialize(url, options={}, &block)
      @options = options
      @url = case url
        when RDF::URI then url
        else RDF::URI.parse(url)
      end
      #TODO: implement a solid interface to Connection
      @connection = Connection.new(@url, @options)
      @client = Client.new(url, @options[:username], @options[:password])
    end

    ##
    # @private
    # @see RDF::Repository#supports?
    def supports?(feature)
      case feature.to_sym
        when :context then true # statement contexts / named graphs
        else super
      end
    end

    #def query(pattern)
    #  debugger
    #  pattern = Query::Pattern.from(pattern)
    #  enum = RDF::Statement.from(pattern)
    #  pattern
    #end

    # @see RDF::Enumerable#each.
    #def each(&block)
    #  if block_given?
    #    binding.pry
    #    #TODO: produce an RDF::Statement, then:
    #    # block.call(RDF::Statement)
    #    #
    #    # @statements.each do |s| block.call(s) end
    #    raise NotImplementedError
    #  else
    #    ::Enumerable::Enumerator.new(self,:each)
    #  end
    #end

    def each(&block)
      query_pattern(RDF::Query::Pattern.new, &block)
    end

    def query_execute(query, &block)
      
      query = query_to_sparql(query)

      # Run the query and process the results.
      results = client.select(query)

      if block_given?
        results.each {|s| yield s }
      else
        enum_for(:raw_query, language, query)
      end
    end
    protected :query_execute

    protected

    # Convert a query to SPARQL.
    def query_to_sparql(query)
      variables = []
      patterns = []
      query.patterns.each do |p|
        p.variables.each {|_,v| variables << v unless variables.include?(v) }
        triple = [p.subject, p.predicate, p.object]
        str = triple.map {|v| serialize(v) }.join(" ")
        # TODO: Wrap in graph block for context!
        if p.optional?
          str = "OPTIONAL { #{str} }"
        end
        patterns << "#{str} ."
      end
      "SELECT #{variables.join(" ")}\nWHERE {\n  #{patterns.join("\n  ")} }"
    end

    def serialize(value)
      case value
      when RDF::Query::Variable then value.to_s
      #else RDF::NTriples::Writer.serialize(map_to_server(value))
      else RDF::NTriples::Writer.serialize(value)
      end
    end

    # @see RDF::Mutable#insert_statement
    def insert_statement(statement)
      #TODO: save the given RDF::Statement.  Don't save duplicates.
      #
      #@statements.push(statement.dup) unless @statements.member?(statement)
      raise NotImplementedError
    end

    # @see RDF::Mutable#delete_statement
    def delete_statement(statement)
      #TODO: delete the given RDF::Statement from the repository.  It's not an error if it doesn't exist.
      #
      # @statements.delete(statement)
      raise NotImplementedError
    end

    def writable?
      true
    end

  end

end
