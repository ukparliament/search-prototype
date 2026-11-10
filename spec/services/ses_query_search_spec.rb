# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SesQuery::Search' do
  let!(:ses_query) { SesQuery::Search.new(term: term, api_client: api_client_class) }
  let!(:api_client_class) { class_double(ApiClient::Get, new: api_client_instance) }
  let!(:api_client_instance) { instance_double(ApiClient::Get, response: mock_response) }

  before do
    allow(Rails.application.credentials).to receive(:dig).with(:test, :api_host).and_return("api.test.url")
    allow(Rails.application.credentials).to receive(:dig).with(:test, :ses_api, :tbdb).and_return("test_tbdb")
    allow(Rails.application.credentials).to receive(:dig).with(:test, :ses_api, :path).and_return("/ses")
    allow(Rails.application.credentials).to receive(:dig).with(:test, :api_subscription_key).and_return("12345")
  end

  describe 'data' do
    let!(:mock_response) { JSON.parse(File.read('spec/fixtures/ses_search_service_example.json')) }

    context 'where input data is nil' do
      let!(:term) { nil }
      let!(:formatted_query) { nil }
      it 'returns nil' do
        expect(ses_query.data).to be_nil
      end
    end

    context 'where a term is submitted' do
      let!(:term) { { value: 'housing' } }
      let!(:formatted_query) { URI("https://api.test.url/ses?tbdb=test_tbdb&service=search&template=service.json&query=housing") }

      it 'returns a hash containing equivalent terms, preferred term, preferred term ID' do
        expect(ses_query.data.map(&:keys)).to eq([[:equivalent_terms, :preferred_term, :preferred_term_id]])
        expect(ses_query.data[0][:equivalent_terms]).to eq(["Accommodation", "Houses"])
        expect(ses_query.data[0][:preferred_term]).to eq("Housing")
        expect(ses_query.data[0][:preferred_term_id]).to eq("91569")
      end
    end

    context 'where SES returns an exact match as an equivalent term' do
      let!(:mock_response) { JSON.parse(File.read('spec/fixtures/securities.json')) }
      let!(:term) { { value: 'Securities' } }
      let!(:formatted_query) { URI("https://api.test.url/ses?tbdb=test_tbdb&service=search&template=service.json&query=Securities") }

      it 'includes that result' do
        expect(ses_query.data.map { |r| r[:preferred_term] }).to eq(["Stocks and shares"])
        expect(ses_query.data.map { |r| r[:equivalent_terms] }).to eq([["Securities"]])
      end
    end

    context 'where SES returns an exact match as the preferred term' do
      let!(:mock_response) { JSON.parse(File.read('spec/fixtures/election_observers.json')) }
      let!(:term) { { value: 'Election observers' } }
      let!(:formatted_query) { URI("https://api.test.url/ses?tbdb=test_tbdb&service=search&template=service.json&query=Election+observers") }

      it 'includes that result' do
        expect(ses_query.data.map { |r| r[:preferred_term] }).to eq(["Election observers"])
      end
    end

    context 'where SES returns no result that matches' do
      let!(:mock_response) { JSON.parse(File.read('spec/fixtures/observers.json')) }
      let!(:term) { { value: 'Observers' } }
      let!(:formatted_query) { URI("https://api.test.url/ses?tbdb=test_tbdb&service=search&template=service.json&query=Observers") }

      it 'excludes that result' do
        expect(ses_query.data.map { |r| r[:preferred_term] }).not_to include("The Observer")
        expect(ses_query.data.map { |r| r[:preferred_term] }).to eq([])
        expect(ses_query.data.map { |r| r[:equivalent_terms] }).to eq([])
      end
    end

    context 'where SES returns multiple matching results' do
      let!(:mock_response) { JSON.parse(File.read('spec/fixtures/army_training_estate.json')) }
      let!(:term) { { value: 'Army' } }
      let!(:formatted_query) { URI("https://api.test.url/ses?tbdb=test_tbdb&service=search&template=service.json&query=Army") }

      it 'includes the more complex result only' do
        expect(ses_query.data.map { |r| r[:preferred_term] }).to eq(["Army Training Estate"])
        expect(ses_query.data.map { |r| r[:preferred_term] }).not_to include("Army")
        expect(ses_query.data.map { |r| r[:preferred_term] }).not_to include("Training")
      end
    end

    context 'where SES returns a topic result' do
      let!(:mock_response) { JSON.parse(File.read('spec/fixtures/ses_search_service_example_tpg.json')) }
      let!(:term) { { value: 'housing' } }
      let!(:formatted_query) { URI("https://api.test.url/ses?tbdb=test_tbdb&service=search&template=service.json&query=housing") }

      it 'does not return the topic' do
        expect(ses_query.data).to eq([])
      end
    end

    context 'where SES returns an intranet term result' do
      let!(:mock_response) { JSON.parse(File.read('spec/fixtures/ses_search_service_example_int.json')) }
      let!(:term) { { value: 'housing' } }
      let!(:formatted_query) { URI("https://api.test.url/ses?tbdb=test_tbdb&service=search&template=service.json&query=housing") }

      it 'does not return the topic' do
        expect(ses_query.data).to eq([])
      end
    end
  end
end
