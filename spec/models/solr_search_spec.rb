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

  describe 'facet_fields' do
    it 'returns an array of strings' do
      expect(SolrSearch.facet_fields).to be_a Array
      expect(SolrSearch.facet_fields.map(&:class).uniq).to eq([String])
    end
  end

  describe 'data' do
    let!(:solr_search) { SolrSearch.new({ filter: { 'field_name' => ['test'] } }) }
    it 'returns a hash containing the search parameters and response' do
      allow(solr_search).to receive(:evaluated_response).and_return(mock_response)
      expect(solr_search.data).to eq({ search_parameters: { :filter => { "field_name" => ["test"] } }, data: mock_response })
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

  describe 'sort' do
    context 'sort parameter is blank' do
      it 'defaults to date desc' do
        expect(solr_search.sort).to eq('date_dt desc')
      end
    end
    context 'sort is date desc' do
      let!(:solr_search) { SolrSearch.new({ sort_by: 'date_desc' }) }
      it 'returns date desc' do
        expect(solr_search.sort).to eq('date_dt desc')
      end
    end
    context 'sort is date asc' do
      let!(:solr_search) { SolrSearch.new({ sort_by: 'date_asc' }) }
      it 'returns date asc' do
        expect(solr_search.sort).to eq('date_dt asc')
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

  describe 'rows' do
    context 'where per page parameter is blank' do
      let!(:solr_search) { SolrSearch.new({ results_per_page: nil }) }
      it 'returns 20' do
        expect(solr_search.rows).to eq(20)
      end
    end

    context 'where per page parameter is not an integer' do
      let!(:solr_search) { SolrSearch.new({ results_per_page: 'test' }) }
      it 'returns 20' do
        expect(solr_search.rows).to eq(20)
      end
    end

    context 'where per page parameter is 10' do
      let!(:solr_search) { SolrSearch.new({ results_per_page: 10 }) }
      it 'returns 20' do
        expect(solr_search.rows).to eq(10)
      end
    end

    context 'where per page parameter is 50' do
      let!(:solr_search) { SolrSearch.new({ results_per_page: 50 }) }
      it 'returns 20' do
        expect(solr_search.rows).to eq(50)
      end
    end

    context 'where per page parameter is 100' do
      let!(:solr_search) { SolrSearch.new({ results_per_page: 100 }) }
      it 'returns 20' do
        expect(solr_search.rows).to eq(100)
      end
    end
  end

  describe 'search_filter' do
    context 'with a single filter' do
      let!(:solr_search) { SolrSearch.new({ filter: { 'field_name' => ['test'] } }) }

      it 'returns an array of filter strings' do
        allow(solr_search).to receive(:evaluated_response).and_return(mock_response)
        expect(solr_search.search_filter).to eq(["field_name:test"])
      end
    end
    context 'with multiple filters' do
      let!(:solr_search) { SolrSearch.new({ filter: { "type_ses" => ["347163"], "subtype_ses" => ["363905"] } }) }

      it 'returns an array of filter strings' do
        allow(solr_search).to receive(:evaluated_response).and_return(mock_response)
        expect(solr_search.search_filter).to eq(["type_ses:347163", "subtype_ses:363905"])
      end
    end
  end

  describe 'search_query' do
    context 'with no query' do
      it 'returns nil' do
        allow(solr_search).to receive(:evaluated_response).and_return(mock_response)
        expect(solr_search.search_query).to eq(nil)
      end
    end
    context 'with a query' do
      let!(:solr_search) { SolrSearch.new({ query: 'horse' }) }

      it 'returns ' do
        allow(solr_search).to receive(:evaluated_response).and_return(mock_response)
        expect(solr_search.search_query).to eq('horse')
      end
    end
  end
end
