require 'rdf'
require 'enumerator'

module RDF::Virtuoso

  class Repository < RDF::Repository

    attr_reader :connection

    def initialize(url_or_options, &block)
      case url_or_options
      when String
        initialize(RDF::URI.new(url_or_options, &block))
      when Hash
        options = url_or_options.dup
        @uri  = options.delete(:uri)
        user = options.delete(:user)
        password = options.delete(:password)
      end
      #TODO: implement a solid interface to Connection
      #@connection = Connection.new(url_or_options)
    end

    def supports?(feature)
      case feature.to_sym
      when :context then true
      else super
      end
    end

    # @see RDF::Enumerable#each.
    def each(&block)
      if block_given?
        #TODO: produce an RDF::Statement, then:
        # block.call(RDF::Statement)
        #
        # @statements.each do |s| block.call(s) end
        raise NotImplementedError
      else
        ::Enumerable::Enumerator.new(self,:each)
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
