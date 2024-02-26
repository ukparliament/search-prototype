require 'rails_helper'

RSpec.describe SolrQuery, type: :model do
  let!(:api_call) { SolrQuery.new({ object_uri: 'test_uri' }) }
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
end
