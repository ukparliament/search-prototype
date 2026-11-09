require 'rails_helper'

RSpec.describe 'ContentTypeObjects', type: :request do
  describe 'GET /show' do

    context 'no object uri is provided' do
      it 'raises a 400 error' do
        get '/objects', params: {}
        expect(response).to have_http_status(400)
      end
    end

    context 'an object uri is provided' do
      let!(:query_object_instance) { instance_double(SolrQuery::Fetch, api_client: test_api_client_class) }
      let!(:test_api_client_class) { class_double(ApiClient::Post, new: test_api_client_instance) }
      let!(:test_api_client_instance) { instance_double(ApiClient::Post, response: 'test api response') }

      before(:each) do
        allow(SolrQuery::Fetch).to receive(:new).and_return(query_object_instance)
      end

      it 'sets up a query object and passes in the uri' do
        expect(query_object_instance).to receive(:data)
        get '/objects', params: { object: 'test_object_uri' }
      end
    end

    context 'no data found for provided object uri' do
      let!(:query_object_instance) { instance_double(SolrQuery::Fetch, api_client: test_api_client_class) }
      let!(:test_api_client_class) { class_double(ApiClient::Post, new: test_api_client_instance) }
      let!(:test_api_client_instance) { instance_double(ApiClient::Post, response: 'test api response') }
      let!(:no_data) { nil }

      before(:each) do
        allow(SolrQuery::Fetch).to receive(:new).and_return(query_object_instance)
        allow(ContentTypeObject).to receive(:generate).and_return(no_data)
      end

      it 'raises a 404 error' do
        expect(query_object_instance).to receive(:data)
        get '/objects', params: { object: 'test_string' }
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'success' do
      let!(:query_object_instance) { instance_double(SolrQuery::Fetch, api_client: test_api_client_class) }
      let!(:test_api_client_class) { class_double(ApiClient::Post, new: test_api_client_instance) }
      let!(:test_api_client_instance) { instance_double(ApiClient::Post, response: 'test api response') }
      let!(:example_object) { Edm.new('test') }

      before(:each) do
        allow(SolrQuery::Fetch).to receive(:new).and_return(query_object_instance)
        allow(ContentTypeObject).to receive(:generate).and_return(example_object)
      end

      it 'returns http success' do
        expect(query_object_instance).to receive(:data)
        get '/objects', params: { object: 'test_string' }
        expect(response).to have_http_status(:ok)
      end

      it 'renders the footer' do
        expect(query_object_instance).to receive(:data)
        get '/objects', params: { :object => 'test_string' }
        expect(response.body).to include('Open Parliament Licence')
        expect(response.body).to include('Accessibility statement')
        expect(response.body).to include('Parliamentary Search')
      end
    end
  end
end