require 'spec_helper'

class Resource < ActiveRDF::Model
end

describe ActiveRDF::Persistence do

  let(:resource) { Resource.new }

  before do
    resource.stub(:id).and_return("some_unique_id")
    resource.stub(:connection).and_return Object.new
    resource.stub(:subject).and_return "#{resource.graph}##{resource.id}"
  end

  describe :destroy do

    it "formats the destroy query correctly" do
      subject = resource.subject_for(resource.id)
      query = 
<<-q
DELETE FROM <#{resource.graph}> { <#{resource.subject}> ?p ?o } 
WHERE { <#{resource.subject}> ?p ?o }
q

      resource.connection.should_receive(:delete).with(query)
      resource.destroy
    end
  end

end
