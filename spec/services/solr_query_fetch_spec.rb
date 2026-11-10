require 'rails_helper'

RSpec.describe SolrQuery::Fetch, type: :model do
  let!(:solr_query) { SolrQuery::Fetch.new(uri: 'test_uri', api_client: api_client_class) }
  let!(:api_client_class) { class_double(ApiClient::Post, new: api_client_instance) }
  let!(:api_client_instance) { instance_double(ApiClient::Post, response: mock_response) }
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

  describe 'data' do
    context 'where response is not an error' do
      it 'returns the first object from the response' do
        expect(solr_query.data).to eq({ 'type_ses' => [12345] })
      end
    end

    context 'where response is a 500 error' do
      let!(:mock_response) { { 'error' => { 'msg' => 'an error', 'code' => 500 } } }

      it 'raises an ExternalServiceError' do
        expect { solr_query.data }.to raise_error(ExternalServiceError)
      end
    end

    context 'where response is a 401 error' do
      let!(:mock_response) { { 'error' => { 'msg' => 'an error', 'code' => 401 } } }

      it 'raises an ExternalServiceUnauthorized' do
        expect { solr_query.data }.to raise_error(UnauthorizedError)
      end
    end

    context 'where response is a 403 error' do
      let!(:mock_response) { { 'error' => { 'msg' => 'an error', 'code' => 403 } } }

      it 'raises an ExternalServiceUnauthorized' do
        expect { solr_query.data }.to raise_error(UnauthorizedError)
      end
    end

    context 'where response is a 404 error' do
      let!(:mock_response) { { 'error' => { 'msg' => 'an error', 'code' => 404 } } }

      it 'raises an ExternalServiceNotFound' do
        expect { solr_query.data }.to raise_error(ObjectNotFoundError)
      end
    end
  end
end
