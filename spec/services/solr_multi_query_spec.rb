require 'rails_helper'

RSpec.describe SolrMultiQuery, type: :model do
  let!(:solr_multi_query) { SolrMultiQuery.new({ object_uris: ['test_uri1', 'test_uri2', 'test_uri3'] }) }
  let!(:mock_response) { {
    "responseHeader" => {
      "status" => 0,
      "QTime" => 4,
      "params" => { "q" => "externalLocation_uri:\"test_external_location_uri\"", "wt" => "json" }
    },
    "response" => { "numFound" => 1, "start" => 0, "docs" => docs_array },
    "highlighting" => { "test_url" => {} }
  } }
  let!(:docs_array) { [{ 'test_string' => 'test1', 'uri' => 'test_uri1', 'all_ses' => [123, 456], 'type_ses' => [12345] },
                       { 'test_string' => 'test2', 'uri' => 'test_uri2', 'all_ses' => [456, 789], 'type_ses' => [23456] },
                       { 'test_string' => 'test3', 'uri' => 'test_uri3', 'all_ses' => [234, 567], 'type_ses' => [34567] },
  ] }
  let!(:error_response) { { 'error' => { 'msg' => 'an error', 'code' => 500 } } }
  let!(:formatted_query) { { fl: nil, q: "uri:test_uri1 || uri:test_uri2 || uri:test_uri3", "q.op": "OR", rows: 500 } }

  before do
    allow(solr_multi_query).to receive(:api_post_request).with(formatted_query).and_return(mock_response.to_json)
  end

  describe 'object_data' do
    it 'returns the data for the object' do
      expect(solr_multi_query.object_data).to match_array(docs_array)
    end
  end

  describe 'object_filter' do
    it 'returns a string ' do
      expect(solr_multi_query.object_filter).to eq("uri:test_uri1 || uri:test_uri2 || uri:test_uri3")
    end
  end

  describe 'all_data' do
    context 'where response is not an error' do
      it 'returns the result of evaluated_response' do
        expect(solr_multi_query.all_data).to eq(mock_response)
      end
    end

    context 'where response is an error' do
      it 'returns the error from the result of evaluated_response' do
        allow(solr_multi_query).to receive(:api_post_request).with(formatted_query).and_return(error_response.to_json)
        expect(solr_multi_query.all_data).to eq({ 'msg' => 'an error', 'code' => 500 })
      end
    end
  end
end
