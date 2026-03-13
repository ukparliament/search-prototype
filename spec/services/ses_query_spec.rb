# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SesQuery' do
  let!(:ses_query) { SesQuery.new(input_data) }

  describe 'data' do
    let!(:mock_response) { File.read('spec/fixtures/ses_search_service_example.json') }

    before do
      allow(ses_query).to receive(:api_get_request).with(formatted_query, false).and_return(mock_response)
    end

    context 'where input data is nil' do
      let!(:input_data) { nil }
      let!(:formatted_query) { nil }
      it 'returns nil' do
        expect(ses_query.data).to be_nil
      end
    end

    context 'where a term is submitted' do
      let!(:input_data) { { value: 'housing' } }
      let!(:formatted_query) { URI("https://api.test.url/ses?TBDB=disp_taxonomy&TEMPLATE=service.json&SERVICE=conceptmap&QUERY=housing") }

      it 'returns a hash containing equivalent terms, perferred term, preferred term ID and topic ID' do
        expect(ses_query.data.map(&:keys)).to eq([[:equivalent_terms, :preferred_term, :preferred_term_id], [:equivalent_terms, :topic_id, :preferred_term, :preferred_term_id]])
        expect(ses_query.data[0][:equivalent_terms]).to eq(["Accommodation", "Houses"])
        expect(ses_query.data[0][:preferred_term]).to eq("Housing")
        expect(ses_query.data[0][:preferred_term_id]).to eq("91569")
        expect(ses_query.data[1][:equivalent_terms]).to eq(["Squatting"])
        expect(ses_query.data[1][:preferred_term]).to eq("Housing")
        expect(ses_query.data[1][:preferred_term_id]).to eq("95629")
        expect(ses_query.data[1][:topic_id]).to eq("95629")
      end
    end
  end
end
