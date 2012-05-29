require 'spec_helper'

class Resource < ActiveRDF::Model
end

describe ActiveRDF::Persistence do

  let(:resource) { Resource.new }

  before do
    resource.stub(:id).and_return("some_unique_id")
    client = double("client")
    resource.stub(:connection).and_return client
  end

  describe :destroy do

    it "formats the destroy query correctly" do
      subject = resource.subject_for(resource.id)
      query = 
<<-q
DELETE FROM <#{resource.graph}> { <#{subject}> ?p ?o } 
WHERE { <#{subject}> ?p ?o }
q

      resource.connection.should_receive(:delete).with(query)
      resource.destroy
    end
  end

end
