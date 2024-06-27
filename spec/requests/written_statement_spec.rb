require 'rails_helper'

RSpec.describe 'Written Statement', type: :request do
  describe 'GET /show' do
    let!(:written_statement_instance) { WrittenStatement.new('type_ses' => [12345]) }

    it 'returns http success' do
      allow_any_instance_of(SolrQuery).to receive(:all_data).and_return({ 'response' => { "docs" => ['test'] } })
      allow_any_instance_of(SolrMultiQuery).to receive(:object_data).and_return({})
      allow_any_instance_of(SesLookup).to receive(:data).and_return({})
      allow(ContentObject).to receive(:generate).and_return(written_statement_instance)
      allow_any_instance_of(WrittenStatement).to receive(:page_title).and_return(written_statement_instance.type[:value] => 'test page title')
      get '/objects', params: { :object => 'test_string' }
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'test data' do
    test_data = JSON.parse(File.read("spec/fixtures/written_statement_test_data.json"))
    docs = test_data["response"]["docs"]

    docs.each_with_index do |doc, index|
      context "object #{index}" do
        let(:data) { doc }

        it 'displays the expected data' do
          written_statement_instance = WrittenStatement.new(data)

          # SES response mocking requires the correct IDs so we're populating it during the test
          test_ses_data = {}

          unless written_statement_instance.subjects.blank?
            written_statement_instance.subjects.each do |subject|
              test_ses_data[subject[:value]] = "SES response for #{subject[:value]}"
            end
          end

          unless written_statement_instance.legislation.blank?
            written_statement_instance.legislation.each do |legislation|
              test_ses_data[legislation[:value]] = "SES response for #{legislation[:value]}"
            end
          end

          allow_any_instance_of(SolrQuery).to receive(:all_data).and_return({ 'response' => { "docs" => ['test'] } })
          allow_any_instance_of(SolrMultiQuery).to receive(:object_data).and_return([])
          allow(ContentObject).to receive(:generate).and_return(written_statement_instance)
          allow_any_instance_of(SesLookup).to receive(:data).and_return(test_ses_data)

          get '/objects', params: { :object => written_statement_instance }

          written_statement_instance.reference.each do |ref|
            expect(CGI::unescapeHTML(response.body)).to include(ref[:value])
          end

          expect(CGI::unescapeHTML(response.body)).to include(written_statement_instance.parliamentary_session[:value])
          expect(CGI::unescapeHTML(response.body)).to include(written_statement_instance.display_link[:value])

          unless written_statement_instance.attachment.blank?
            expect(CGI::unescapeHTML(response.body)).to include(written_statement_instance.attachment[:value])
          end

          unless written_statement_instance.notes.blank?
            expect(CGI::unescapeHTML(response.body)).to include(written_statement_instance.notes[:value])
          end

          unless written_statement_instance.related_item_ids.blank?
            # TODO: test related items
            # written_statement_instance.related_item_ids.each do |related_item_uri|
            #   expect(CGI::unescapeHTML(response.body)).to include(related_item_uri)
            # end
          end

          unless written_statement_instance.subjects.blank?
            written_statement_instance.subjects.each do |subject|
              if subject[:field_name] == 'subject_ses'
                expect(CGI::unescapeHTML(response.body)).to include("SES response for #{subject[:value]}")
              elsif subject[:field_name] == 'subject_t'
                expect(CGI::unescapeHTML(response.body)).to include(subject[:value].to_s)
              end
            end
          end

          unless written_statement_instance.legislation.blank?
            written_statement_instance.legislation.each do |legislation|
              if legislation[:field_name] == 'legislationTitle_ses'
                expect(CGI::unescapeHTML(response.body)).to include("SES response for #{legislation[:value]}")
              elsif legislation[:field_name] == 'legislationTitle_t'
                expect(CGI::unescapeHTML(response.body)).to include("#{legislation[:value]}")
              end
            end
          end
        end
      end
    end
  end
end