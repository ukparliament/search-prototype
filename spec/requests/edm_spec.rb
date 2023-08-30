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

    docs.each_with_index do |doc, index|
      context "object #{index}" do
        let(:data) { doc }

        it 'returns http success' do
          edm_instance = Edm.new(data)
          allow_any_instance_of(ApiCall).to receive(:object_data).and_return('test')
          allow(ContentObject).to receive(:generate).and_return(edm_instance)
          get '/search-prototype/objects', params: { :object => edm_instance }
          expect(response).to have_http_status(:ok)
        end

        it 'displays the expected data' do
          edm_instance = Edm.new(data)
          allow_any_instance_of(ApiCall).to receive(:object_data).and_return('test')
          allow(ContentObject).to receive(:generate).and_return(edm_instance)
          get '/search-prototype/objects', params: { :object => edm_instance }
          # expect(response.body).to include("QUESTIONS AND ANSWERS ON THE FLOOR")
          puts "#{edm_instance.motion_text}"
          expect(response.body).to include(edm_instance.motion_text)
        end
      end
    end
  end
end