require 'rails_helper'

RSpec.describe SolrMultiQuery, type: :model do
  let!(:api_call) { SolrMultiQuery.new({ object_uris: ['test_uri1', 'test_uri2', 'test_uri2'] }) }
  let!(:mock_response) { {
    "responseHeader" => {
      "status" => 0,
      "QTime" => 4,
      "params" => { "q" => "externalLocation_uri:\"test_external_location_uri\"", "wt" => "json" }
    },
    "response" => {
      "numFound" => 1,
      "start" => 0,
      "docs" => [{ 'test_string' => 'test1', 'uri' => 'test_uri1', 'all_ses' => [123, 456] },
                 { 'test_string' => 'test2', 'uri' => 'test_uri2', 'all_ses' => [456, 789] },
                 { 'test_string' => 'test3', 'uri' => 'test_uri3', 'all_ses' => [234, 567] },
      ] },
    "highlighting" => { "test_url" => {} }
  } }

  describe 'object_data' do
    it 'returns the data for the object' do
      allow(api_call).to receive(:evaluated_response).and_return(mock_response)
      expect(api_call.object_data).to match_array([{ 'test_string' => 'test1', 'uri' => 'test_uri1', 'all_ses' => [123, 456] },
                                                   { 'test_string' => 'test2', 'uri' => 'test_uri2', 'all_ses' => [456, 789] },
                                                   { 'test_string' => 'test3', 'uri' => 'test_uri3', 'all_ses' => [234, 567] },
                                                  ])
    end
  end

  describe 'all_ses_ids' do
    it 'returns a flattened array of all_ses from all objects returned' do
      allow(api_call).to receive(:evaluated_response).and_return(mock_response)
      expect(api_call.all_ses_ids).to match_array([123, 234, 456, 567, 789])
    end
  end

  describe 'ruby_uri' do
    it 'returns a ruby uri with the base prepended' do
      expect(api_call.ruby_uri).to be_a(URI)
      expect(api_call.ruby_uri.to_s).to eq('https://api.parliament.uk/new-solr/select?q=(uri:%22test_uri1%22%20OR%20uri:%22test_uri2%22%20OR%20uri:%22test_uri2%22)&rows=50')
    end
  end
end
