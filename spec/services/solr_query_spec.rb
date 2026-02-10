require 'rails_helper'

RSpec.describe SolrQuery, type: :model do
  let!(:solr_query) { SolrQuery.new({ object_uri: 'test_uri' }) }
  let!(:mock_response) { {
    "responseHeader" => {
      "status" => 0,
      "QTime" => 4,
      "params" => { "q" => "externalLocation_uri:\"test_external_location_uri\"", "wt" => "json" }
    },
    "response" => {
      "numFound" => 1,
      "start" => 0,
      "docs" => [{ 'type_ses' => [12345] }]
    },
    "highlighting" => { "test_url" => {} }
  } }
  let!(:error_response) { { 'error' => { 'msg' => 'an error', 'code' => 500 } } }
  let!(:formatted_query) { { q: "uri:test_uri" } }

  before do
    allow(solr_query).to receive(:api_post_request).with(formatted_query).and_return(mock_response.to_json)
  end

  describe 'object_data' do
    it 'returns data from the first doc within the response from all_data' do
      expect(solr_query.object_data).to eq({ 'type_ses' => [12345] })
    end
  end

  describe 'all_data' do
    context 'where response is not an error' do
      it 'returns the result of evaluated_response' do
        expect(solr_query.all_data).to eq(mock_response)
      end
    end

    context 'where response is an error' do
      it 'returns the error from the result of evaluated_response' do
        allow(solr_query).to receive(:api_post_request).with(formatted_query).and_return(error_response.to_json)
        expect(solr_query.all_data).to eq({ 'msg' => 'an error', 'code' => 500 })
      end
    end
  end
end
