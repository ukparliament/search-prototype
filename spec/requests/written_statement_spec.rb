require 'rails_helper'

RSpec.describe 'Written Statement', type: :request do
  describe 'GET /show' do
    let!(:written_statement_instance) { WrittenStatement.new('test') }

    it 'returns http success' do
      allow_any_instance_of(ApiCall).to receive(:object_data).and_return('test')
      allow(ContentObject).to receive(:generate).and_return(written_statement_instance)
      allow_any_instance_of(WrittenStatement).to receive(:ses_data).and_return(written_statement_instance.type => 'written statement')
      get '/search-prototype/objects', params: { :object => 'test_string' }
      expect(response).to have_http_status(:ok)
    end
  end

  xdescribe 'test data' do
    test_data = JSON.parse(File.read("spec/fixtures/written_statement_test_data.json"))
    docs = test_data["response"]["docs"]

    docs.each_with_index do |doc, index|
      context "object #{index}" do
        let(:data) { doc }

        it 'displays the expected data' do
          written_statement_instance = WrittenStatement.new(data)
          allow_any_instance_of(ApiCall).to receive(:object_data).and_return('test')
          allow(ContentObject).to receive(:generate).and_return(written_statement_instance)
          get '/search-prototype/objects', params: { :object => written_statement_instance }

          expect(CGI::unescapeHTML(response.body)).to include(written_statement_instance.reference)
          expect(CGI::unescapeHTML(response.body)).to include(written_statement_instance.session)
          expect(CGI::unescapeHTML(response.body)).to include(written_statement_instance.display_link)

          unless written_statement_instance.attachment.blank?
            expect(CGI::unescapeHTML(response.body)).to include(written_statement_instance.attachment)
          end

          unless written_statement_instance.notes.blank?
            expect(CGI::unescapeHTML(response.body)).to include(written_statement_instance.notes)
          end

          unless written_statement_instance.related_items.blank?
            written_statement_instance.related_items.each do |related_item|
              expect(CGI::unescapeHTML(response.body)).to include(related_item.to_s)
            end
          end

          unless written_statement_instance.subjects.blank?
            written_statement_instance.subjects.each do |subject|
              expect(CGI::unescapeHTML(response.body)).to include(subject.to_s)
            end
          end

          unless written_statement_instance.legislation.blank?
            written_statement_instance.legislation.each do |legislation|
              expect(CGI::unescapeHTML(response.body)).to include(legislation.to_s)
            end
          end
        end
      end
    end
  end
end