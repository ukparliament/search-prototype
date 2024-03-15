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

  describe 'user_requested_page' do
    context 'for 0' do
      let!(:solr_search) { SolrSearch.new({ page: 0 }) }

      it 'returns 1' do
        expect(solr_search.user_requested_page).to eq(1)
      end
    end

    context 'for 1' do
      let!(:solr_search) { SolrSearch.new({ page: 1 }) }

      it 'returns 1' do
        expect(solr_search.user_requested_page).to eq(1)
      end
    end

    context 'for any other value' do
      let!(:solr_search) { SolrSearch.new({ page: 9999 }) }

      it 'returns that value' do
        expect(solr_search.user_requested_page).to eq(9999)
      end
    end
  end

  describe 'current_page' do
    context 'for 0' do
      let!(:solr_search) { SolrSearch.new({ page: 0 }) }

      it 'returns 0' do
        expect(solr_search.current_page).to eq(0)
      end
    end

    context 'for 1' do
      let!(:solr_search) { SolrSearch.new({ page: 1 }) }

      it 'returns 0' do
        expect(solr_search.current_page).to eq(0)
      end
    end

    context 'for any other value' do
      let!(:solr_search) { SolrSearch.new({ page: 9999 }) }

      it 'returns one below that value' do
        expect(solr_search.current_page).to eq(9998)
      end
    end
  end

  describe 'start' do
    context 'page parameter is blank' do
      it 'returns 0' do
        expect(solr_search.start).to eq(0)
      end
    end

    context 'page parameter is present' do
      context 'first page requested' do
        let!(:solr_search) { SolrSearch.new({ page: 1 }) }

        it 'returns 0' do
          # first page is results 0-19 if rows is set to 20
          expect(solr_search.start).to eq(0)
        end
      end
      context 'second page requested' do
        # second page is results 20-39 if rows is set to 20
        let!(:solr_search) { SolrSearch.new({ page: 2 }) }

        it 'returns number of rows per page times the page number' do
          expect(solr_search.start).to eq(20)
        end
      end
      context 'third page requested' do
        # thid page is results 40-59 if rows is set to 20
        let!(:solr_search) { SolrSearch.new({ page: 3 }) }

        it 'returns number of rows per page times the page number' do
          expect(solr_search.start).to eq(40)
        end
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
