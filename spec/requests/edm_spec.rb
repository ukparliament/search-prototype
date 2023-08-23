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

  describe 'test data' do
    test_data = JSON.parse(File.read("spec/fixtures/edm_test_data.json"))
    docs = test_data["response"]["docs"]

    let!(:edm_instance) { Edm.new(first_doc) }
    let!(:first_doc) { docs.first }

    it 'returns http success' do
      allow_any_instance_of(ApiCall).to receive(:object_data).and_return('test')
      allow(ContentObject).to receive(:generate).and_return(edm_instance)
      get '/search-prototype/objects', params: { :object => edm_instance }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("QUESTIONS AND ANSWERS ON THE FLOOR")
    end
  end
end