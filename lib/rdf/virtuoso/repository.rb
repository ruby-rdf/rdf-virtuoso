require 'rdf'
require 'enumerator'

module RDF::Virtuoso

  class Repository < RDF::Repository

    attr_reader :url
    attr_reader :options
    attr_reader :connection

    alias_method :uri, :url

    def initialize(url, options={}, &block)
      @options = options
      @url = case url
      when RDF::URI then url
      else RDF::URI.parse(url)
      end
      #TODO: implement a solid interface to Connection
      @connection = Connection.new(@url, @options)
    end

    def supports?(feature)
      case feature.to_sym
      when :context then true
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
