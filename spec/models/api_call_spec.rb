require 'rails_helper'

RSpec.describe ApiCall, type: :model do
  let!(:api_call) { ApiCall.new({ object_uri: 'test_uri' }) }
  let!(:mock_response) { {
    "responseHeader" => {
      "status" => 0,
      "QTime" => 4,
      "params" => { "q" => "externalLocation_uri:\"test_external_location_uri\"", "wt" => "json" }
    },
    "response" => {
      "numFound" => 1,
      "start" => 0,
      "docs" => [{ test_string: 'test' }]
    },
    "highlighting" => { "test_url" => {} }
  } }

  describe 'object_data' do
    it 'returns the data for the object' do
      allow(api_call).to receive(:evaluated_response).and_return(mock_response)
      expect(api_call.object_data).to eq({ test_string: 'test' })
    end
  end

  describe 'ruby_uri' do
    it 'returns a ruby uri with the base prepended' do
      expect(api_call.ruby_uri).to be_a(URI)
      expect(api_call.ruby_uri.to_s).to eq('https://api.parliament.uk/search-mock/objects.json?object=test_uri')
    end
  end
end
