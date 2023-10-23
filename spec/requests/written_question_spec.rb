require 'rails_helper'

RSpec.describe 'Written Question', type: :request do
  describe 'GET /show' do
    let!(:written_question_instance) { WrittenQuestion.new('test') }

    it 'returns http success' do
      allow_any_instance_of(ApiCall).to receive(:object_data).and_return('test')
      allow(ContentObject).to receive(:generate).and_return(written_question_instance)
      allow_any_instance_of(WrittenQuestion).to receive(:ses_data).and_return(written_question_instance.type => 'written question')
      allow(written_question_instance).to receive(:tabled?).and_return(true)
      get '/search-prototype/objects', params: { :object => 'test_string' }
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
              test_ses_data[subject] = "SES response for #{subject}"
            end
          end

          unless written_question_instance.legislation.blank?
            written_question_instance.legislation.each do |legislation|
              test_ses_data[legislation] = "SES response for #{legislation}"
            end
          end
          
          allow_any_instance_of(ApiCall).to receive(:object_data).and_return('test')
          allow(ContentObject).to receive(:generate).and_return(written_question_instance)
          allow(written_question_instance).to receive(:tabled?).and_return(true)
          allow_any_instance_of(SesLookup).to receive(:data).and_return(test_ses_data)

          get '/search-prototype/objects', params: { :object => written_question_instance }
          expect(CGI::unescapeHTML(response.body)).to include(written_question_instance.uin.join('; '))
          expect(CGI::unescapeHTML(response.body)).to include(written_question_instance.session)

          # procedure

          unless written_question_instance.notes.blank?
            expect(CGI::unescapeHTML(response.body)).to include(written_question_instance.notes)
          end

          unless written_question_instance.registered_interest_declared.blank?
            expect(CGI::unescapeHTML(response.body)).to include(written_question_instance.registered_interest_declared)
          end

          expect(CGI::unescapeHTML(response.body)).to include(written_question_instance.display_link)

          unless written_question_instance.tabled?
            expect(CGI::unescapeHTML(response.body)).to include(written_question_instance.attachment)
          end

          # grouped for answer

          unless written_question_instance.tabled? || written_question_instance.withdrawn?
            expect(CGI::unescapeHTML(response.body)).to include('Transferred')
          end

          # failed oral
          # unstarred

          unless written_question_instance.related_items.blank?
            written_question_instance.related_items.each do |related_item|
              expect(CGI::unescapeHTML(response.body)).to include(related_item.to_s)
            end
          end

          unless written_question_instance.subjects.blank?
            written_question_instance.subjects.each do |subject|
              expect(CGI::unescapeHTML(response.body)).to include(subject.to_s)
            end
          end

          unless written_question_instance.legislation.blank?
            written_question_instance.legislation.each do |legislation|
              expect(CGI::unescapeHTML(response.body)).to include(legislation.to_s)
            end
          end
        end
      end
    end
  end
end