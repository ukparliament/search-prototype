require 'rails_helper'

RSpec.describe 'ContentObjects', type: :request do
  describe 'GET /show' do
    let!(:edm_instance) { Edm.new('test') }

    it 'returns http success' do
      allow_any_instance_of(ApiCall).to receive(:object_data).and_return('test')
      allow(ContentObject).to receive(:generate).and_return(edm_instance)
      get '/search-prototype/objects', params: { :object => 'test_string' }
      expect(response).to have_http_status(:ok)
    end
  end
end