require 'uuid'
require 'transaction/simple'
require 'rdf'

module ActiveRDF

  class Model
    include ActiveAttr::Model
    include ActiveModel::Dirty
    include ActiveRDF::Persistence

  end
end
