require 'rails_helper'

RSpec.describe 'ContentTypeObjects', type: :request do
  describe 'GET /show' do
    let!(:edm_instance) { Edm.new('test') }

    context 'success' do
      it 'returns http success' do
        allow_any_instance_of(SolrQuery).to receive(:all_data).and_return({ 'response' => { "docs" => [{ 'type_ses' => [12345] }] } })
        allow_any_instance_of(SesLookup).to receive(:data).and_return({})
        allow(ContentTypeObject).to receive(:generate).and_return(edm_instance)
        get '/objects', params: { :object => 'test_string' }
        expect(response).to have_http_status(:ok)
      end
      it 'renders the footer' do
        allow_any_instance_of(SolrQuery).to receive(:all_data).and_return({ 'response' => { "docs" => [{ 'type_ses' => [12345] }] } })
        allow_any_instance_of(SesLookup).to receive(:data).and_return({})
        allow(ContentTypeObject).to receive(:generate).and_return(edm_instance)
        get '/objects', params: { :object => 'test_string' }
        expect(response).to have_http_status(:ok)
        # expect(response.body).to include('API directory')
        expect(response.body).to include('Open Parliament Licence')
        expect(response.body).to include('Accessibility statement')
        expect(response.body).to include('Parliamentary Search')
      end
    end
  end
end