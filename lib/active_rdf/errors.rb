module ActiveRDF

  # Base class for all ActiveRDF errors
  class ActiveRDFError < StandardError
  end

  class ResourceNotFoundError < ActiveRDFError
  end
end  
