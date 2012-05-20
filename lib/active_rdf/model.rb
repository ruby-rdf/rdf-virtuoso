require 'uuid'
require 'transaction/simple'
require 'rdf'
require 'active_rdf/reflections'

module ActiveRDF

  class Model
    include ActiveAttr::Model
    include ActiveModel::Dirty
    include ActiveRDF::Persistence

    class << self
      attr_accessor :reflections

      private

      def inherited(child)
        child.instance_variable_set :@reflections, @reflections.dup
        super
      end      
    end

    def type
      self.class.type
    end    

    def to_param
      self.id.gsub((self.class.graph / '#').to_s, '')
    end

    def graph
      self.class.graph
    end

    extend Reflections
    
    @reflections = HashWithIndifferentAccess.new
    
  end

end
