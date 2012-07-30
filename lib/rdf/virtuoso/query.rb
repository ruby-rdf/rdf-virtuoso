
module RDF::Virtuoso

  ##
  # A SPARQL query builder.
  #
  # @example Iterating over all found solutions
  #   query.each_solution { |solution| puts solution.inspect }
  #
  class Query < RDF::Query
    ##
    # @return [Symbol]
    # @see    http://www.w3.org/TR/rdf-sparql-query/#QueryForms
    attr_reader :form

    ##
    # @return [Hash{Symbol => Object}]
    attr_reader :options

    ##
    # @return [Array<[key, RDF::Value]>]
    attr_reader :values


    attr_reader :data_values

    ##
    # Creates a boolean `ASK` query.
    #
    # @param  [Hash{Symbol => Object}] options
    # @return [Query]
    # @see    http://www.w3.org/TR/rdf-sparql-query/#ask
    def self.ask(options = {})
      self.new(:ask, options)
    end

    ##
    # Creates a tuple `SELECT` query.
    #
    # @param  [Array<Symbol>]          variables
    # @param  [Hash{Symbol => Object}] options
    # @return [Query]
    # @see    http://www.w3.org/TR/rdf-sparql-query/#select
    def self.select(*variables)
      options = variables.last.is_a?(Hash) ? variables.pop : {}
      self.new(:select, options).select(*variables)
    end

    ##
    # Creates a `DESCRIBE` query.
    #
    # @param  [Array<Symbol, RDF::URI>] variables
    # @param  [Hash{Symbol => Object}]  options
    # @return [Query]
    # @see    http://www.w3.org/TR/rdf-sparql-query/#describe
    def self.describe(*variables)
      options = variables.last.is_a?(Hash) ? variables.pop : {}
      self.new(:describe, options).describe(*variables)
    end

    ##
    # Creates a graph `CONSTRUCT` query.
    #
    # @param  [Array<RDF::Query::Pattern, Array>] patterns
    # @param  [Hash{Symbol => Object}]            options
    # @return [Query]
    # @see    http://www.w3.org/TR/rdf-sparql-query/#construct
    def self.construct(*patterns)
      options = patterns.last.is_a?(Hash) ? patterns.pop : {}
      self.new(:construct, options).construct(*patterns) # FIXME
    end

    ##
    # Creates an `UPDATE` query.
    #
    # @param  [Array<RDF::Query::Pattern, Array>] patterns
    # @param  [Hash{Symbol => Object}]            options
    # @return [Query]
    # @see    http://www.w3.org/TR/rdf-sparql-query/#construct
    def self.insert_data(*patterns)
      # options = variables.last.is_a?(Hash) ? variables.pop : {}
      options = patterns.last.is_a?(Hash) ? patterns.pop : {}
      self.new(:insert_data, options).insert_data(*patterns) 
    end

    def self.insert(*patterns)
      # options = variables.last.is_a?(Hash) ? variables.pop : {}
      options = patterns.last.is_a?(Hash) ? patterns.pop : {}
      self.new(:insert, options).insert(*patterns) 
    end

    def self.delete_data(*patterns)
      options = patterns.last.is_a?(Hash) ? patterns.pop : {}
      self.new(:delete_data, options).delete_data(*patterns)
    end

    def self.delete(*patterns)
      options = patterns.last.is_a?(Hash) ? patterns.pop : {}
      self.new(:delete, options).delete(*patterns) 
    end
    
#    def self.delete(*variables)
#      options = variables.last.is_a?(Hash) ? variables.pop : {}
#      self.new(:delete, options).delete(*variables)      
#    end

    def self.create(*variables)
      options = variables.last.is_a?(Hash) ? variables.pop : {}
      self.new(:create, options).create(variables.first)
    end

    def self.drop(*variables)
      options = variables.last.is_a?(Hash) ? variables.pop : {}
      self.new(:drop, options).drop(variables.first)
    end

    def self.clear(*variables)
      options = variables.last.is_a?(Hash) ? variables.pop : {}
      self.new(:clear, options).clear(variables.first)
    end

    ##
    # @param  [Symbol, #to_s]          form
    # @param  [Hash{Symbol => Object}] options
    # @yield  [query]
    # @yieldparam [Query]
    def initialize(form = :ask, options = {}, &block)
      @form = form.respond_to?(:to_sym) ? form.to_sym : form.to_s.to_sym
      super([], options, &block)
    end

    ##
    # @return [Query]
    # @see    http://www.w3.org/TR/rdf-sparql-query/#ask
    def ask
      @form = :ask
      self
    end

    ##
    # @param  [Array<Symbol>] variables
    # @return [Query]
    # @see    http://www.w3.org/TR/rdf-sparql-query/#select
    def select(*variables)
      @values = variables.map { |var| [var, RDF::Query::Variable.new(var)] }
      self
    end

    ##
    # @param  [Array<Symbol>] variables
    # @return [Query]
    # @see    http://www.w3.org/TR/rdf-sparql-query/#describe
    def describe(*variables)
      @values = variables.map { |var|
        [var, var.is_a?(RDF::URI) ? var : RDF::Query::Variable.new(var)]
      }
      self
    end

    ##
    # @param  [Array<RDF::Query::Pattern, Array>] patterns
    # @return [Query]
    # @see    http://www.w3.org/TR/rdf-sparql-query/#construct
    def construct(*patterns)
      new_patterns = []
      patterns.each do |pattern|
        new_patterns << pattern.map do |value|
          if value.is_a?(Symbol)
            value = RDF::Query::Variable.new(value)
          elsif value.is_a?(RDF::URI) 
            value = value
          else
            value = RDF::Literal.new(value)
          end
        end
      end
      @data_values = build_patterns(new_patterns)
      self
    end


    ##
    # @param  [Array<RDF::Query::Pattern, Array>] patterns
    # @return [Query]
    # @see    http://www.w3.org/TR/rdf-sparql-query/#select
    def insert_data(*patterns)
      new_patterns = []
      patterns.each do |values|
        new_patterns << values.map { |var| [var, var.is_a?(RDF::URI) ? var : var] }
      end
      @data_values = new_patterns #build_patterns(new_patterns)
      self
    end

    def insert(*patterns)
      new_patterns = []
      patterns.each do |pattern|
        new_patterns << pattern.map do |value|
          if value.is_a?(Symbol)
            value = RDF::Query::Variable.new(value)
          elsif value.is_a?(RDF::URI) 
            value = value
          else
            value = RDF::Literal.new(value)
          end
        end
      end
      @data_values = build_patterns(new_patterns)
      self
    end
    
    def delete_data(*patterns)
      new_patterns = []
      patterns.each do |values|
        new_patterns << values.map { |var| [var, var.is_a?(RDF::URI) ? var : var] }
      end
      @data_values = new_patterns #build_patterns(new_patterns)
      self
    end

    def delete(*patterns)
      new_patterns = []
      patterns.each do |pattern|
        new_patterns << pattern.map do |value|
          if value.is_a?(Symbol)
            value = RDF::Query::Variable.new(value)
          elsif value.is_a?(RDF::URI) 
            value = value
          else
            value = RDF::Literal.new(value)
          end
        end
      end
      @data_values = build_patterns(new_patterns)
      self
    end
    
#    def delete(*variables)
#      @values = variables.map { |var|
#        [var, var.is_a?(RDF::URI) ? var : RDF::Query::Variable.new(var)]
#      }
#      self
#    end

    def create(uri)
      options[:graph] = uri
      self
    end

    def drop(uri)
      options[:graph] = uri
      self
    end

    def clear(uri)
      options[:graph] = uri
      self
    end

    # @param RDF::URI uri
    # @return [Query]
    # @see http://www.w3.org/TR/rdf-sparql-query/#specDataset
    def from(uri)
      options[:from] = uri
      self
    end

    # @param RDF::URI uri
    # @return [Query]
    def graph(uri)
      options[:graph] = uri
      self
    end

    ##
    # @param  [Array<RDF::Query::Pattern, Array>] patterns
    # @return [Query]
    # @see    http://www.w3.org/TR/rdf-sparql-query/#GraphPattern
    def where(*patterns)
      @patterns += build_patterns(patterns)
      self
    end

    alias_method :whether, :where

    ##
    # @param  [Array<Symbol, String>] variables
    # @return [Query]
    # @see    http://www.w3.org/TR/rdf-sparql-query/#modOrderBy
    def order(*variables)
      options[:order_by] = variables
      self
    end

    alias_method :order_by, :order

    ##
    # @return [Query]
    # @see    http://www.w3.org/TR/rdf-sparql-query/#modDistinct
    def distinct(state = true)
      options[:distinct] = state
      self
    end

    ##
    # @return [Query]
    # @see    http://www.w3.org/TR/rdf-sparql-query/#modReduced
    def reduced(state = true)
      options[:reduced] = state
      self
    end

    ##
    # @param  [Integer, #to_i] start
    # @return [Query]
    # @see    http://www.w3.org/TR/rdf-sparql-query/#modOffset
    def offset(start)
      slice(start, nil)
    end

    ##
    # @param  [Integer, #to_i] length
    # @return [Query]
    # @see    http://www.w3.org/TR/rdf-sparql-query/#modResultLimit
    def limit(length)
      slice(nil, length)
    end

    ##
    # @param  [Integer, #to_i] start
    # @param  [Integer, #to_i] length
    # @return [Query]
    def slice(start, length)
      options[:offset] = start.to_i if start
      options[:limit] = length.to_i if length
      self
    end

    ##
    # @return [Query]
    # @see    http://www.w3.org/TR/rdf-sparql-query/#prefNames
    def prefix(string)
      (options[:prefixes] ||= []) << string
      self
    end

    ##
    # @return [Query]
    # @see    http://www.w3.org/TR/rdf-sparql-query/#prefNames
    def prefixes(prefixes = nil)
      options[:prefixes] ||= []
      options[:prefixes] += prefixes.to_a
      self
    end

    ##
    # @return [Query]
    # @see    http://www.w3.org/TR/rdf-sparql-query/#optionals
    def optional(*patterns)
      (options[:optionals] ||= []) << build_patterns(patterns)
      self
    end

    ##
    # @return [Query]
    # @see    http://www.w3.org/TR/rdf-sparql-query/#minus
    def minus(*patterns)
      (options[:minuses] ||= []) << build_patterns(patterns)
      self
    end
    
    def union(*patterns)
      (options[:unions] ||= []) << build_patterns(patterns)
      self
    end

    ##
    # @private
    def build_patterns(patterns)
      patterns.map do |pattern|
        case pattern
        when RDF::Query::Pattern then pattern
        else RDF::Query::Pattern.new(*pattern.to_a)
        end
      end
    end

    ##
    # @private
    def filter(string)
      (options[:filters] ||= []) << string
      self
    end

    def filters(filters = nil)
      options[:filters] ||= []
      options[:filters] += filters.to_a
      self
    end
    
    ##
    # @return [Boolean]
    def true?
      case result
      when TrueClass, FalseClass then result
      when Enumerable then !result.empty?
      else false
      end
    end

    ##
    # @return [Boolean]
    def false?
      !true?
    end

    ##
    # @return [Enumerable<RDF::Query::Solution>]
    def solutions
      result
    end

    ##
    # @yield  [statement]
    # @yieldparam [RDF::Statement]
    # @return [Enumerator]
    def each_statement(&block)
      result.each_statement(&block)
    end

    ##
    # @return [Object]
    def result
      @result ||= execute
    end

    ##
    # @return [Object]
    def execute
      raise NotImplementedError
    end

    ##
    # Returns the string representation of this query.
    #
    # @return [String]
    def to_s
      buffer = [form.to_s.gsub('_', ' ').upcase]
      case form
      when :select, :describe
        buffer << 'DISTINCT' if options[:distinct]
        buffer << 'REDUCED'  if options[:reduced]
        buffer << (values.empty? ? '*' : values.map { |v| serialize_value(v[1]) }.join(' '))
      when :construct
        buffer << '{'
        buffer += serialize_patterns(@data_values)
        buffer << '}'
        
        # for virtuoso inserts
      when :insert_data
        buffer << "INTO GRAPH #{serialize_value(options[:graph])}" if options[:graph]
        buffer << '{'
        @data_values.each do |triple|
          buffer << (triple.map { |v| serialize_value(v[1]) }.join(' ') + ' .')
        end
        buffer << '}'          
        
      when :insert
        buffer << "INTO GRAPH #{serialize_value(options[:graph])}" if options[:graph]
        # buffer += serialize_patterns(options[:template])
        # (@data_values.map { |v| puts v[1].inspect; puts 'xxx ' } )
        buffer << '{'
        buffer += serialize_patterns(@data_values)
        buffer << '}'          
        
      when :delete_data
        buffer << "FROM #{serialize_value(options[:graph])}" #if options[:graph]
        buffer << '{'
        @data_values.each do |triple|
          buffer << (triple.map { |v| serialize_value(v[1]) }.join(' ') + ' .')
        end
        buffer << '}'          

      when :delete
        buffer << "FROM #{serialize_value(options[:graph])}" if options[:graph]
        buffer << '{'
        buffer += serialize_patterns(@data_values)
        buffer << '}'           

      when :create, :drop
        buffer << 'SILENT' if options[:silent]
        buffer << "GRAPH #{serialize_value(options[:graph])}"

      when :clear
        buffer << "GRAPH #{serialize_value(options[:graph])}"

      end

      buffer << "FROM #{serialize_value(options[:from])}" if options[:from]

      unless patterns.empty? && ([:describe, :insert_data, :delete_data, :create, :clear, :drop].include?(form))
        buffer << 'WHERE {'

        buffer << '{' if options[:unions]

        buffer += serialize_patterns(patterns)
        if options[:optionals]
          options[:optionals].each do |patterns|
            buffer << 'OPTIONAL {'
            buffer += serialize_patterns(patterns)
            buffer << '}'
          end
        end

        if options[:minuses]
          options[:minuses].each do |patterns|
            buffer << 'MINUS {'
            buffer += serialize_patterns(patterns)
            buffer << '}'
          end
        end
                
        if options[:filters]
          buffer += options[:filters].map { |filter| "FILTER(#{filter})" }
        end
        buffer << '}'

        if options[:unions]
          options[:unions].each do |patterns|
            buffer << 'UNION {'
            buffer += serialize_patterns(patterns)
            buffer << '}'
          end
          buffer << '}'
        end

      end

      if options[:order_by]
        buffer << 'ORDER BY'
        buffer += options[:order_by].map { |var| var.is_a?(String) ? var : "?#{var}" }
      end

      buffer << "OFFSET #{options[:offset]}" if options[:offset]
      buffer << "LIMIT #{options[:limit]}"   if options[:limit]
      options[:prefixes].reverse.each {|e| buffer.unshift("PREFIX #{e}") } if options[:prefixes]

      buffer.join(' ')
    end

    ##
    # @private
    def serialize_patterns(patterns)
      patterns.map do |p|
        p.to_triple.map { |v| serialize_value(v) }.join(' ') + " ."
      end
    end

    ##
    # Outputs a developer-friendly representation of this query to `stderr`.
    #
    # @return [void]
    def inspect!
      warn(inspect)
      self
    end

    ##
    # Returns a developer-friendly representation of this query.
    #
    # @return [String]
    def inspect
      sprintf("#<%s:%#0x(%s)>", self.class.name, __id__, to_s)
    end

    ##
    # Serializes an RDF::Value into a format appropriate for select, construct, and where clauses
    #
    # @param  [RDF::Value]
    # @return [String]
    # @private
    def serialize_value(value)
      # SPARQL queries are UTF-8, but support ASCII-style Unicode escapes, so
      # the N-Triples serializer is fine unless it's a variable:
      case
      when value.variable? then value.to_s
      else RDF::NTriples.serialize(value)
      end
    end
  end
end
