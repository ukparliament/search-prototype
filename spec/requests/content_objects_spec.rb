require 'rails_helper'

RSpec.describe 'ContentObjects', type: :request do
  describe 'GET /show' do
    let!(:edm_instance) { Edm.new('test') }

    context 'success' do
      it 'returns http success' do
        allow_any_instance_of(SolrQuery).to receive(:object_data).and_return('test')
        allow_any_instance_of(Edm).to receive(:ses_data).and_return(edm_instance.type => 'early day motion')
        allow(ContentObject).to receive(:generate).and_return(edm_instance)
        get '/objects', params: { :object => 'test_string' }
        expect(response).to have_http_status(:ok)
      end
      it 'renders the footer' do
        allow_any_instance_of(SolrQuery).to receive(:object_data).and_return('test')
        allow_any_instance_of(Edm).to receive(:ses_data).and_return(edm_instance.type => 'early day motion')
        allow(ContentObject).to receive(:generate).and_return(edm_instance)
        get '/objects', params: { :object => 'test_string' }
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('API directory')
        expect(response.body).to include('Open Parliament Licence')
        expect(response.body).to include('Accessibility statement')
        expect(response.body).to include('Parliamentary Search')

      end
    end

    context '500 error' do
      it 'renders the error page' do
        allow_any_instance_of(SolrQuery).to receive(:object_data).and_return('statusCode' => 500)
        allow_any_instance_of(Edm).to receive(:ses_data).and_return(edm_instance.type => 'early day motion')
        allow(ContentObject).to receive(:generate).and_return(edm_instance)
        get '/objects', params: { :object => 'test_string' }
        expect(response.body).to include("An error occurred")
      end
    end
  end
end