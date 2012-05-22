require 'active_support'
require 'active_model'
require 'active_attr'
require 'active_rdf/exceptions'
require 'active_rdf/errors'
require 'active_rdf/version'

module ActiveRDF
  extend ActiveSupport::Autoload

  autoload :Model
  autoload :Persistence
  autoload :Reflection
end
