require 'uuid'
require 'transaction/simple'
require 'rdf'
require 'active_rdf/reflections'

module ActiveRDF

  class Model
    include ActiveAttr::Model
    include ActiveModel::Dirty
    include ActiveRDF::Persistence

    # All children should have these attributes
    attribute :id,          type: String
    attribute :subject,     type: String  
    

    class << self
      attr_accessor :reflections

      def graph
        url = RDF::URI.new("http://data.deichman.no")
        if defined?(Rails)
          url = url.join Rails.env unless (Rails.env.production? || Rails.env.staging?)
        end
        url / self.name.downcase.pluralize
      end

      def encode(string)
        [string].pack('m0')
      end

      def decode(string)
        string.unpack('m')[0]
      end      

      def from_param(param)
        decode param
      end
      
      private

      def inherited(child)
        child.instance_variable_set :@reflections, @reflections.dup
        super
      end      
    end  # Class methods

    def type
      self.class.type
    end    

    # When using an object's subject, which comes in the format http://example.org/object#123 as 
    # a query param, we must encode it first
    def to_param
      self.class.encode self.subject
    end

    def graph
      self.class.graph
    end

    extend Reflections
    
    @reflections = HashWithIndifferentAccess.new
    
  end

end
