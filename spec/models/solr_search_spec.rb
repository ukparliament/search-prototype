require 'rails_helper'

RSpec.describe SolrSearch, type: :model do
  let!(:solr_search) { SolrSearch.new({}) }
  let!(:mock_response) { {
    "responseHeader" => {
      "status" => 0,
      "QTime" => 4,
      "params" => { "q" => "externalLocation_uri:\"test_external_location_uri\"", "wt" => "json" }
    },
    "response" => {
      "numFound" => 1,
      "start" => 0,
      "docs" => [
        { 'test_string' => 'test string 1', 'uri' => 'test1' },
        { 'test_string' => 'test string 2', 'uri' => 'test2' },
        { 'test_string' => 'test string 3', 'uri' => 'test3' },
      ]
    },
    "highlighting" => { "test_url" => {} }
  } }

  describe 'object_data' do
    it 'returns an array of data' do
      allow(solr_search).to receive(:evaluated_response).and_return(mock_response)
      expect(solr_search.object_data).to eq([
                                              { 'test_string' => 'test string 1', 'uri' => 'test1' },
                                              { 'test_string' => 'test string 2', 'uri' => 'test2' },
                                              { 'test_string' => 'test string 3', 'uri' => 'test3' },
                                            ])
    end
  end

  describe 'start' do
    context 'page parameter is blank' do
      it 'returns 0' do
        expect(solr_search.start).to eq(0)
      end
    end

    context 'page parameter is present' do
      let!(:solr_search) { SolrSearch.new({ page: 5 }) }

      it 'returns the number of rows needed to reach that page number' do
        expect(solr_search.start).to eq(5 * solr_search.rows)
      end
    end
  end

  describe 'search_filter' do
    context 'with a single filter' do
      let!(:solr_search) { SolrSearch.new({ filter: { field_name: 'field_name', value: 'test' } }) }

      it 'returns a string' do
        allow(solr_search).to receive(:evaluated_response).and_return(mock_response)
        expect(solr_search.search_filter).to eq("field_name:test")
      end
    end
  end
end
