require 'rails_helper'

RSpec.describe 'Written Question', type: :request do
  describe 'GET /show' do
    let!(:written_question_instance) { WrittenQuestion.new('type_ses' => [12345]) }

    it 'returns http success' do
      allow_any_instance_of(SolrQuery).to receive(:object_data).and_return('test')
      allow_any_instance_of(SolrMultiQuery).to receive(:object_data).and_return([])
      allow(ContentObject).to receive(:generate).and_return(written_question_instance)
      allow_any_instance_of(WrittenQuestion).to receive(:ses_data).and_return(written_question_instance.type[:value] => 'written question')
      allow(written_question_instance).to receive(:tabled?).and_return(true)
      get '/objects', params: { :object => 'test_string' }
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'test data' do
    test_data = JSON.parse(File.read("spec/fixtures/written_question_test_data.json"))
    docs = test_data["response"]["docs"]

    docs.each_with_index do |doc, index|
      context "object #{index}" do
        let(:data) { doc }

        it 'displays the expected data' do
          written_question_instance = WrittenQuestion.new(data)

          # SES response mocking requires the correct IDs so we're populating it during the test
          test_ses_data = {}

          unless written_question_instance.subjects.blank?
            written_question_instance.subjects.each do |subject|
              test_ses_data[subject[:value]] = "SES response for #{subject[:value]}"
            end
          end

          unless written_question_instance.legislation.blank?
            written_question_instance.legislation.each do |legislation|
              test_ses_data[legislation[:value]] = "SES response for #{legislation[:value]}"
            end
          end

          allow_any_instance_of(SolrQuery).to receive(:object_data).and_return('test')
          allow_any_instance_of(SolrMultiQuery).to receive(:object_data).and_return([])
          allow(ContentObject).to receive(:generate).and_return(written_question_instance)
          allow(written_question_instance).to receive(:tabled?).and_return(true)
          allow_any_instance_of(SesLookup).to receive(:data).and_return(test_ses_data)

          get '/objects', params: { :object => written_question_instance }
          expect(CGI::unescapeHTML(response.body)).to include(written_question_instance.uin.map { |h| h[:value] }.join('; '))
          expect(CGI::unescapeHTML(response.body)).to include(written_question_instance.parliamentary_session[:value])

          # procedure

          unless written_question_instance.notes.blank?
            expect(CGI::unescapeHTML(response.body)).to include(written_question_instance.notes[:value])
          end

          if written_question_instance.registered_interest_declared
            expect(CGI::unescapeHTML(response.body)).to include(written_question_instance.registered_interest_declared[:value])
          end

          expect(CGI::unescapeHTML(response.body)).to include(written_question_instance.display_link[:value])

          unless written_question_instance.tabled?
            expect(CGI::unescapeHTML(response.body)).to include(written_question_instance.attachment[:value])
          end

          # grouped for answer

          unless written_question_instance.tabled? || written_question_instance.withdrawn?
            expect(CGI::unescapeHTML(response.body)).to include('Transferred')
          end

          # failed oral
          # unstarred

          unless written_question_instance.related_items.blank?
            written_question_instance.related_items.each do |related_item|
              # TODO: meaningfully test related items
            end
          end

          unless written_question_instance.subjects.blank?
            written_question_instance.subjects.each do |subject|
              # page should show the SES name for each subject ID
              expect(CGI::unescapeHTML(response.body)).to include(subject[:value].to_s)
            end
          end

          unless written_question_instance.legislation.blank?
            written_question_instance.legislation.each do |legislation|
              expect(CGI::unescapeHTML(response.body)).to include(legislation[:value].to_s)
            end
          end
        end
      end
    end
  end
end