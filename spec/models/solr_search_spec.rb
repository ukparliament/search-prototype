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

  describe 'result_uris' do
    it 'extracts the URIs from all returned objects' do
      allow(solr_search).to receive(:evaluated_response).and_return(mock_response)
      expect(solr_search.result_uris).to match_array(['test1', 'test2', 'test3'])
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

  describe 'query_string' do
    context 'where neither query or type are provided' do
      it 'returns nil' do
        expect(solr_search.query_string).to be_nil
      end
    end

    context 'where query is provided' do
      let!(:solr_search) { SolrSearch.new({ query: 'a search term' }) }

      it 'returns a partial url with the search included' do
        expect(solr_search.query_string).to eq('q=%22a search term%22')
      end
    end

    context 'where a fiter is provided' do
      let!(:solr_search) { SolrSearch.new({ filter: { value: 12345, field_name: 'type_ses' } }) }

      it 'returns a partial url with the filter included' do
        expect(solr_search.query_string).to eq("q=type_ses:12345")
      end
    end

    context 'where query and a filter are both provided' do
      let!(:solr_search) { SolrSearch.new({ query: 'a search term', filter: { value: 12345, field_name: 'type_ses' } }) }

      it 'returns a partial url with the filter and search term included' do
        expect(solr_search.query_string).to eq("q=%22a search term%22&type_ses:12345")
      end
    end
  end

  describe 'query_chain' do
    context 'where a number of rows is set differently to the solr default (hard coded)' do
      it 'includes the custom row count in the string' do
        expect(solr_search.query_chain).to eq("rows=20")
      end
    end

    context 'where a page is specified' do
      let!(:solr_search) { SolrSearch.new({ page: 12 }) }

      it 'returns the correct start parameter in addition to the rows parameter' do
        expect(solr_search.query_chain).to eq('rows=20&start=240')
      end
    end

    context 'where query and type are both provided' do
      let!(:solr_search) { SolrSearch.new({ query: 'a search term', filter: { value: 12345, field_name: 'type_ses' }, page: 12 }) }

      it 'returns all filters combined into a single string' do
        expect(solr_search.query_chain).to eq('rows=20&start=240&q=%22a search term%22&type_ses:12345')
      end
    end
  end

  describe 'ruby_uri' do
    it 'returns a ruby uri with the base prepended and the preset number of rows' do
      expect(solr_search.ruby_uri).to be_a(URI)
      expect(solr_search.ruby_uri.to_s).to eq('https://api.parliament.uk/new-solr/select?rows=20')
    end
  end
end
