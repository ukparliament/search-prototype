# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SesQuery' do
  let!(:ses_query) { SesQuery.new(input_data) }

  describe 'data' do
    let!(:mock_response) { File.read('spec/fixtures/ses_search_service_example.json') }

    before do
      allow(Rails.application.credentials).to receive(:dig).with(:test, :api_host).and_return("api.test.url")
      allow(Rails.application.credentials).to receive(:dig).with(:test, :ses_api, :path).and_return("/ses")
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
      let!(:formatted_query) { URI("https://api.test.url/ses?TBDB=disp_taxonomy&TEMPLATE=service.json&SERVICE=conceptmap&MATCH=exact&QUERY=housing") }

      it 'returns a hash containing equivalent terms, perferred term, preferred term ID' do
        expect(ses_query.data.map(&:keys)).to eq([[:equivalent_terms, :preferred_term, :preferred_term_id]])
        expect(ses_query.data[0][:equivalent_terms]).to eq(["Accommodation", "Houses"])
        expect(ses_query.data[0][:preferred_term]).to eq("Housing")
        expect(ses_query.data[0][:preferred_term_id]).to eq("91569")
      end
    end

    context 'where SES returns an exact match as an equivalent term' do
      let!(:mock_response) { File.read('spec/fixtures/securities.json') }
      let!(:input_data) { { value: 'Securities' } }
      let!(:formatted_query) { URI("https://api.test.url/ses?TBDB=disp_taxonomy&TEMPLATE=service.json&SERVICE=conceptmap&MATCH=exact&QUERY=Securities") }

      it 'includes that result' do
        expect(ses_query.data.map { |r| r[:preferred_term] }).to eq(["Stocks and shares"])
        expect(ses_query.data.map { |r| r[:equivalent_terms] }).to eq([["Securities"]])
      end
    end

    context 'where SES returns an exact match as the preferred term' do
      let!(:mock_response) { File.read('spec/fixtures/election_observers.json') }
      let!(:input_data) { { value: 'Election observers' } }
      let!(:formatted_query) { URI("https://api.test.url/ses?TBDB=disp_taxonomy&TEMPLATE=service.json&SERVICE=conceptmap&MATCH=exact&QUERY=Election+observers") }

      it 'includes that result' do
        expect(ses_query.data.map { |r| r[:preferred_term] }).to eq(["Election observers"])
      end
    end

    context 'where SES returns no result that matches' do
      let!(:mock_response) { File.read('spec/fixtures/observers.json') }
      let!(:input_data) { { value: 'Observers' } }
      let!(:formatted_query) { URI("https://api.test.url/ses?TBDB=disp_taxonomy&TEMPLATE=service.json&SERVICE=conceptmap&MATCH=exact&QUERY=Observers") }

      it 'excludes that result' do
        expect(ses_query.data.map { |r| r[:preferred_term] }).not_to include("The Observer")
        expect(ses_query.data.map { |r| r[:preferred_term] }).to eq([])
        expect(ses_query.data.map { |r| r[:equivalent_terms] }).to eq([])
      end
    end

    context 'where SES returns multiple matching results' do
      let!(:mock_response) { File.read('spec/fixtures/army_training_estate.json') }
      let!(:input_data) { { value: 'Army' } }
      let!(:formatted_query) { URI("https://api.test.url/ses?TBDB=disp_taxonomy&TEMPLATE=service.json&SERVICE=conceptmap&MATCH=exact&QUERY=Army") }

      it 'includes the more complex result only' do
        expect(ses_query.data.map { |r| r[:preferred_term] }).to eq(["Army Training Estate"])
        expect(ses_query.data.map { |r| r[:preferred_term] }).not_to include("Army")
        expect(ses_query.data.map { |r| r[:preferred_term] }).not_to include("Training")
      end
    end

    context 'where SES returns a topic result' do
      let!(:mock_response) { File.read('spec/fixtures/ses_search_service_example_tpg.json') }
      let!(:input_data) { { value: 'housing' } }
      let!(:formatted_query) { URI("https://api.test.url/ses?TBDB=disp_taxonomy&TEMPLATE=service.json&SERVICE=conceptmap&MATCH=exact&QUERY=housing") }

      it 'does not return the topic' do
        expect(ses_query.data).to eq([])
      end
    end
  end
end
