# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SesDataProcessor' do
  let!(:mock_response) { JSON.parse(File.read('spec/fixtures/ses_search_service_example.json')) }
  let!(:ses_data_processor) { SesDataProcessor.new(
    terms: mock_response.dig("terms"),
    query_string: query_string,
    query_string_processor: QueryStringProcessor,
    exact_match_required: exact_match
  ) }

  describe 'process_terms' do

    context 'in non-exact mode' do
      let!(:exact_match) { false }

      context 'when the query is not present in the returned terms' do
        let!(:query_string) { 'horses' }

        it 'returns an empty array' do
          expect(ses_data_processor.process_terms).to eq([])
        end
      end

      context 'when the query is present in full as an equivalent term' do
        let!(:query_string) { 'houses' }

        it 'returns the matching term' do
          expect(ses_data_processor.process_terms).to eq([{ equivalent_terms: ["Accommodation", "Houses"], preferred_term: "Housing", preferred_term_id: "91569" }])
        end
      end

      context 'when the query is present in full as a preferred term' do
        let!(:query_string) { 'housing' }

        it 'returns the matching term' do
          expect(ses_data_processor.process_terms).to eq([{ equivalent_terms: ["Accommodation", "Houses"], preferred_term: "Housing", preferred_term_id: "91569" }])
        end
      end

      context 'when the query is present as part of an equivalent term' do
        let!(:query_string) { 'house' }

        it 'does not return the term' do
          expect(ses_data_processor.process_terms).to eq([])
        end
      end

      context 'when the query is present as part of a preferred term' do
        let!(:query_string) { 'housin' }

        it 'does not return the term' do
          expect(ses_data_processor.process_terms).to eq([])
        end
      end

      context 'when an equivalent term forms part of the query' do
        let!(:query_string) { 'large houses' }

        it 'returns the matching term' do
          expect(ses_data_processor.process_terms).to eq([{ equivalent_terms: ["Accommodation", "Houses"], preferred_term: "Housing", preferred_term_id: "91569" }])
        end
      end

      context 'when a preferred term forms part of the query' do
        let!(:query_string) { 'housing crisis' }

        it 'returns the matching term' do
          expect(ses_data_processor.process_terms).to eq([{ equivalent_terms: ["Accommodation", "Houses"], preferred_term: "Housing", preferred_term_id: "91569" }])
        end
      end
    end

    context 'in exact mode' do
      let!(:exact_match) { true }

      context 'when the query is not present in the returned terms' do
        let!(:query_string) { 'horses' }

        it 'returns an empty array' do
          expect(ses_data_processor.process_terms).to eq([])
        end
      end

      context 'when the query is present in full as an equivalent term' do
        let!(:query_string) { 'houses' }

        it 'returns the matching term' do
          expect(ses_data_processor.process_terms).to eq([{ equivalent_terms: ["Accommodation", "Houses"], preferred_term: "Housing", preferred_term_id: "91569" }])
        end
      end

      context 'when the query is present in full as a preferred term' do
        let!(:query_string) { 'housing' }

        it 'returns the matching term' do
          expect(ses_data_processor.process_terms).to eq([{ equivalent_terms: ["Accommodation", "Houses"], preferred_term: "Housing", preferred_term_id: "91569" }])
        end
      end

      context 'when the query is present as part of an equivalent term' do
        let!(:query_string) { 'house' }

        it 'does not return the term' do
          expect(ses_data_processor.process_terms).to eq([])
        end
      end

      context 'when the query is present as part of a preferred term' do
        let!(:query_string) { 'housin' }

        it 'does not return the term' do
          expect(ses_data_processor.process_terms).to eq([])
        end
      end

      context 'when an equivalent term forms part of the query' do
        let!(:query_string) { 'large houses' }

        it 'does not return the term' do
          expect(ses_data_processor.process_terms).to eq([])
        end
      end

      context 'when a preferred term forms part of the query' do
        let!(:query_string) { 'housing crisis' }

        it 'does not return the term' do
          expect(ses_data_processor.process_terms).to eq([])
        end
      end
    end

  end
end
