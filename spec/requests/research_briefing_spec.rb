require 'rails_helper'

RSpec.describe 'ContentObjects', type: :request do
  describe 'GET /show' do
    let!(:research_briefing_instance) { ResearchBriefing.new('test') }

    it 'returns http success' do
      allow_any_instance_of(ApiCall).to receive(:object_data).and_return('test')
      allow(ContentObject).to receive(:generate).and_return(research_briefing_instance)
      get '/search-prototype/objects', params: { :object => 'test_string' }
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'test data' do
    test_data = JSON.parse(File.read("spec/fixtures/research_briefing_test_data.json"))
    docs = test_data["response"]["docs"]

    docs.each_with_index do |doc, index|
      context "object #{index}" do
        let(:data) { doc }

        it 'displays the expected data' do
          research_briefing_instance = ResearchBriefing.new(data)
          allow_any_instance_of(ApiCall).to receive(:object_data).and_return('test')
          allow(ContentObject).to receive(:generate).and_return(research_briefing_instance)
          get '/search-prototype/objects', params: { :object => research_briefing_instance }

          expect(CGI::unescapeHTML(response.body)).to include(research_briefing_instance.reference)
          expect(CGI::unescapeHTML(response.body)).to include(research_briefing_instance.display_link)

          if research_briefing_instance.published?
            expect(CGI::unescapeHTML(response.body)).to include('Published by')
          end

          unless research_briefing_instance.related_items.blank?
            research_briefing_instance.related_items.each do |related_item|
              expect(CGI::unescapeHTML(response.body)).to include(related_item.to_s)
            end
          end

          unless research_briefing_instance.subjects.blank?
            research_briefing_instance.subjects.each do |subject|
              expect(CGI::unescapeHTML(response.body)).to include(subject.to_s)
            end
          end

          unless research_briefing_instance.topics.blank?
            research_briefing_instance.topics.each do |topic|
              expect(CGI::unescapeHTML(response.body)).to include(topic.to_s)
            end
          end

          unless research_briefing_instance.legislation.blank?
            research_briefing_instance.legislation.each do |legislation|
              expect(CGI::unescapeHTML(response.body)).to include(legislation.to_s)
            end
          end
        end
      end
    end
  end
end