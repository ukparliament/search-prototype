require 'rails_helper'

RSpec.describe 'Edm', type: :request do
  describe 'GET /show' do
    let!(:edm_instance) { Edm.new('test') }

    it 'returns http success' do
      allow_any_instance_of(ApiCall).to receive(:object_data).and_return('test')
      allow_any_instance_of(Edm).to receive(:ses_data).and_return(edm_instance.type => 'early day motion')
      allow(ContentObject).to receive(:generate).and_return(edm_instance)
      get '/search-prototype/objects', params: { :object => 'test_string' }
      expect(response).to have_http_status(:ok)
    end
  end

  xdescribe 'test data' do
    test_data = JSON.parse(File.read("spec/fixtures/edm_test_data.json"))
    docs = test_data["response"]["docs"]

    docs.each_with_index do |doc, index|
      context "object #{index}" do
        let(:data) { doc }

        it 'displays the expected data' do
          edm_instance = Edm.new(data)
          allow_any_instance_of(ApiCall).to receive(:object_data).and_return('test')
          allow(ContentObject).to receive(:generate).and_return(edm_instance)
          get '/search-prototype/objects', params: { :object => edm_instance }

          expect(CGI::unescapeHTML(response.body)).to include(edm_instance.reference)
          expect(CGI::unescapeHTML(response.body)).to include(edm_instance.session)
          expect(CGI::unescapeHTML(response.body)).to include(edm_instance.motion_text)

          allow_any_instance_of(SesLookup).to receive(:data).and_return(ses_data)

          expect(CGI::unescapeHTML(response.body)).to include('SES API test response')
          expect(CGI::unescapeHTML(response.body)).to include(edm_instance.display_link)

          unless edm_instance.other_supporters.blank?
            edm_instance.other_supporters.each do |supporter|
              expect(CGI::unescapeHTML(response.body)).to include(supporter.to_s)
            end
          end

          unless edm_instance.subjects.blank?
            edm_instance.subjects.each do |subject|
              expect(CGI::unescapeHTML(response.body)).to include(subject.to_s)
            end
          end

          unless edm_instance.legislation.blank?
            edm_instance.legislation.each do |legislation|
              expect(CGI::unescapeHTML(response.body)).to include(legislation.to_s)
            end
          end
        end
      end
    end
  end
end