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
  let!(:formatted_query) { { q: "uri:test_uri" } }

  before do
    allow(solr_query).to receive(:api_post_request).with(formatted_query).and_return(mock_response.to_json)
  end

  describe 'object_data' do
    context 'where type_ses is present for the first result' do
      it 'returns data from the first doc within the response from all_data' do
        expect(solr_query.object_data).to eq({ 'type_ses' => [12345] })
      end
    end
    context 'where type_ses is NOT present for the first result' do
      let!(:mock_response) { {
        "responseHeader" => {
          "status" => 0,
          "QTime" => 4,
          "params" => { "q" => "externalLocation_uri:\"test_external_location_uri\"", "wt" => "json" }
        },
        "response" => {
          "numFound" => 1,
          "start" => 0,
          "docs" => [{ 'type_ses' => [] }]
        },
        "highlighting" => { "test_url" => {} }
      } }
      it 'raises an ExternalServiceNotFound error' do
        expect { solr_query.object_data }.to raise_error ExternalServiceNotFound
      end
    end
  end

  describe 'all_data' do
    context 'where response is not an error' do
      it 'returns the result of evaluated_response' do
        expect(solr_query.all_data).to eq(mock_response)
      end
    end

    context 'where response is a 500 error' do
      let!(:mock_response) { { 'error' => { 'msg' => 'an error', 'code' => 500 } } }

      it 'raises an ExternalServiceError' do
        expect { solr_query.all_data }.to raise_error(ExternalServiceError)
      end
    end

    context 'where response is a 401 error' do
      let!(:mock_response) { { 'error' => { 'msg' => 'an error', 'code' => 401 } } }

      it 'raises an ExternalServiceUnauthorized' do
        expect { solr_query.all_data }.to raise_error(ExternalServiceUnauthorized)
      end
    end

    context 'where response is a 403 error' do
      let!(:mock_response) { { 'error' => { 'msg' => 'an error', 'code' => 403 } } }

      it 'raises an ExternalServiceUnauthorized' do
        expect { solr_query.all_data }.to raise_error(ExternalServiceUnauthorized)
      end
    end

    context 'where response is a 404 error' do
      let!(:mock_response) { { 'error' => { 'msg' => 'an error', 'code' => 404 } } }

      it 'raises an ExternalServiceNotFound' do
        expect { solr_query.all_data }.to raise_error(ExternalServiceNotFound)
      end
    end
  end
end
