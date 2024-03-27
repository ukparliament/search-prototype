require 'rails_helper'

RSpec.describe ApiCall, type: :model do
  let!(:api_call) { SolrQuery.new({ object_uri: 'test_uri' }) }
  let!(:search_params) { { q: "type_ses:12345" } }

  describe 'evaluated_response' do
    let!(:api_call) { ApiCall.new({ value: 92347, field_name: 'type_ses' }) }
    let!(:test_response) { ActionDispatch::TestResponse.new }
    let!(:deserialised_response) { { "terms" => { "1" => "a", "2" => "b" } } }
    let!(:serialised_response) { "{\"terms\":{\"1\":\"a\",\"2\":\"b\"}}" }

    it 'parses the response' do
      allow(api_call).to receive(:api_response).and_return(test_response)
      allow(test_response).to receive(:body).and_return(serialised_response)
      expect(api_call.send(:evaluated_response)).to eq(deserialised_response)
    end
  end
end
