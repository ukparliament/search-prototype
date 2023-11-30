require 'rails_helper'

RSpec.describe 'Edm', type: :request do
  describe 'GET /show' do
    let!(:edm_instance) { Edm.new('type_ses' => [12345]) }

    it 'returns http success' do
      allow_any_instance_of(SolrQuery).to receive(:object_data).and_return('test')
      allow_any_instance_of(Edm).to receive(:ses_data).and_return(edm_instance.type[:value] => 'early day motion')
      allow(ContentObject).to receive(:generate).and_return(edm_instance)
      get '/objects', params: { :object => 'test_string' }
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'test data' do
    test_data = JSON.parse(File.read("spec/fixtures/edm_test_data.json"))
    docs = test_data["response"]["docs"]

    docs.each_with_index do |doc, index|
      context "object #{index}" do
        let(:data) { doc }

        it 'displays the expected data' do
          edm_instance = Edm.new(data)

          # SES response mocking requires the correct IDs so we're populating it during the test
          test_ses_data = { edm_instance.primary_sponsor[:value] => "SES response for #{edm_instance.primary_sponsor[:value]}" }

          unless edm_instance.other_sponsors.blank?
            edm_instance.other_sponsors.each do |sponsor|
              test_ses_data[sponsor[:value]] = "SES response for #{sponsor[:value]}"
            end
          end

          unless edm_instance.subjects.blank?
            edm_instance.subjects.each do |subject|
              test_ses_data[subject[:value]] = "SES response for #{subject[:value]}"
            end
          end

          unless edm_instance.legislation.blank?
            edm_instance.legislation.each do |legislation|
              test_ses_data[legislation[:value]] = "SES response for #{legislation[:value]}"
            end
          end

          allow_any_instance_of(SolrQuery).to receive(:object_data).and_return('test')
          allow(ContentObject).to receive(:generate).and_return(edm_instance)
          allow_any_instance_of(SesLookup).to receive(:data).and_return(test_ses_data)

          get '/objects', params: { :object => edm_instance }

          expect(CGI::unescapeHTML(response.body)).to include(edm_instance.reference[:value])
          expect(CGI::unescapeHTML(response.body)).to include(edm_instance.parliamentary_session[:value])
          expect(CGI::unescapeHTML(response.body)).to include(edm_instance.motion_text[:value])
          expect(CGI::unescapeHTML(response.body)).to include("SES response for #{edm_instance.primary_sponsor[:value]}")
          expect(CGI::unescapeHTML(response.body)).to include(edm_instance.display_link[:value])

          unless edm_instance.other_sponsors.blank?
            edm_instance.other_sponsors.each do |sponsor|
              expect(CGI::unescapeHTML(response.body)).to include("SES response for #{sponsor[:value]}")
            end
          end

          unless edm_instance.subjects.blank?
            edm_instance.subjects.each do |subject|
              expect(CGI::unescapeHTML(response.body)).to include("SES response for #{subject[:value]}")
            end
          end

          unless edm_instance.legislation.blank?
            edm_instance.legislation.each do |legislation|
              expect(CGI::unescapeHTML(response.body)).to include("SES response for #{legislation[:value]}")
            end
          end
        end
      end
    end
  end
end