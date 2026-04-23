require 'rails_helper'

RSpec.describe SolrSearch, type: :model do
  let!(:solr_search) { SolrSearch.new(query_expander: expand_query_class) }
  let(:expand_query_class) { class_double(QueryExpander, new: expand_query_instance) }
  let(:expand_query_instance) { instance_double(QueryExpander) }
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
  let!(:formatted_query) { { fl: "uri type_ses subtype_ses",
                             fq: ["{!tag=field_name}field_name:(test)"],
                             "json.facet": "{\"type_sesrollup\":{\"type\":\"terms\",\"field\":\"type_sesrollup\",\"limit\":-1,\"mincount\":1,\"domain\":{\"excludeTags\":\"type_sesrollup\"}},\"legislature_ses\":{\"type\":\"terms\",\"field\":\"legislature_ses\",\"limit\":100,\"mincount\":1,\"domain\":{\"excludeTags\":\"legislature_ses\"}},\"date_year\":{\"type\":\"terms\",\"field\":\"date_year\",\"limit\":100,\"mincount\":1,\"domain\":{\"excludeTags\":\"date_year\"}},\"date_month\":{\"type\":\"terms\",\"field\":\"date_month\",\"limit\":100,\"mincount\":1,\"domain\":{\"excludeTags\":\"date_month\"}},\"session_s\":{\"type\":\"terms\",\"field\":\"session_s\",\"limit\":100,\"mincount\":1,\"domain\":{\"excludeTags\":\"session_s\"}},\"department_ses\":{\"type\":\"terms\",\"field\":\"department_ses\",\"limit\":100,\"mincount\":1,\"domain\":{\"excludeTags\":\"department_ses\"}},\"member_ses\":{\"type\":\"terms\",\"field\":\"member_ses\",\"limit\":100,\"mincount\":1,\"domain\":{\"excludeTags\":\"member_ses\"}},\"primaryMember_ses\":{\"type\":\"terms\",\"field\":\"primaryMember_ses\",\"limit\":100,\"mincount\":1,\"domain\":{\"excludeTags\":\"primaryMember_ses\"}},\"answeringMember_ses\":{\"type\":\"terms\",\"field\":\"answeringMember_ses\",\"limit\":100,\"mincount\":1,\"domain\":{\"excludeTags\":\"answeringMember_ses\"}},\"legislativeStage_ses\":{\"type\":\"terms\",\"field\":\"legislativeStage_ses\",\"limit\":100,\"mincount\":1,\"domain\":{\"excludeTags\":\"legislativeStage_ses\"}},\"legislationTitle_ses\":{\"type\":\"terms\",\"field\":\"legislationTitle_ses\",\"limit\":100,\"mincount\":1,\"domain\":{\"excludeTags\":\"legislationTitle_ses\"}},\"publisher_ses\":{\"type\":\"terms\",\"field\":\"publisher_ses\",\"limit\":100,\"mincount\":1,\"domain\":{\"excludeTags\":\"publisher_ses\"}},\"subject_ses\":{\"type\":\"terms\",\"field\":\"subject_ses\",\"limit\":100,\"mincount\":1,\"domain\":{\"excludeTags\":\"subject_ses\"}}}",
                             q: "test",
                             "q.op": "AND",
                             rows: 20,
                             sort: "date_dt desc",
                             start: 0 } }

  before do
    allow(solr_search).to receive(:api_post_request).with(formatted_query).and_return(mock_response.to_json)
  end

  describe 'facet_fields' do
    it 'returns an array of strings' do
      expect(SolrSearch.facet_fields).to be_a Array
      expect(SolrSearch.facet_fields.map(&:class).uniq).to eq([String])
    end
  end

  describe 'data' do
    context 'where there are no errors' do
      # note: using [] to avoid query expansion in this test
      let!(:solr_search) { SolrSearch.new(query: "[test]", filter: { 'field_name' => ['test'] }) }
      it 'returns a hash containing the search parameters and response' do
        expect(solr_search.data).to eq({ search_parameters: { :query => "[test]", :filter => { "field_name" => ["test"] } }, data: mock_response })
      end
      context 'where solr returned an error' do
        context 'with a 500 error' do
          let!(:mock_response) { { 'error' => { 'msg' => 'an error', 'code' => 500 } } }

          it 'raises an ExternalServiceError' do
            expect { solr_search.data }.to raise_exception ExternalServiceError
          end
        end
        context 'with a 401 error' do
          let!(:mock_response) { { 'error' => { 'msg' => 'an error', 'code' => 401 } } }

          it 'raises an ExternalServiceError' do
            expect { solr_search.data }.to raise_exception ExternalServiceUnauthorized
          end
        end
        context 'with a 403 error' do
          let!(:mock_response) { { 'error' => { 'msg' => 'an error', 'code' => 403 } } }

          it 'raises an ExternalServiceError' do
            expect { solr_search.data }.to raise_exception ExternalServiceUnauthorized
          end
        end
        context 'with a 404 error' do
          let!(:mock_response) { { 'error' => { 'msg' => 'an error', 'code' => 404 } } }

          it 'raises an ExternalServiceError' do
            expect { solr_search.data }.to raise_exception ExternalServiceNotFound
          end
        end
      end
    end
  end

  describe 'user_requested_page' do
    context 'for 0' do
      let!(:solr_search) { SolrSearch.new(page: 0) }

      it 'returns 1' do
        expect(solr_search.user_requested_page).to eq(1)
      end
    end

    context 'for 1' do
      let!(:solr_search) { SolrSearch.new(page: 1) }

      it 'returns 1' do
        expect(solr_search.user_requested_page).to eq(1)
      end
    end

    context 'for any other value' do
      let!(:solr_search) { SolrSearch.new(page: 9999) }

      it 'returns that value' do
        expect(solr_search.user_requested_page).to eq(9999)
      end
    end
  end

  describe 'current_page' do
    context 'for 0' do
      let!(:solr_search) { SolrSearch.new(page: 0) }

      it 'returns 0' do
        expect(solr_search.current_page).to eq(0)
      end
    end

    context 'for 1' do
      let!(:solr_search) { SolrSearch.new(page: 1) }

      it 'returns 0' do
        expect(solr_search.current_page).to eq(0)
      end
    end

    context 'for any other value' do
      let!(:solr_search) { SolrSearch.new(page: 9999) }

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
      let!(:solr_search) { SolrSearch.new(sort_by: 'date_desc') }
      it 'returns date desc' do
        expect(solr_search.sort).to eq('date_dt desc')
      end
    end
    context 'sort is date asc' do
      let!(:solr_search) { SolrSearch.new(sort_by: 'date_asc') }
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
        let!(:solr_search) { SolrSearch.new(page: 1, results_per_page: 20) }

        it 'returns 0' do
          # first page is results 0-19 if rows is set to 10
          expect(solr_search.start).to eq(0)
        end
      end
      context 'second page requested' do
        # second page is results 10-19 if rows is set to 10
        let!(:solr_search) { SolrSearch.new(page: 2, results_per_page: 20) }

        it 'returns number of rows per page times the page number' do
          expect(solr_search.start).to eq(20)
        end
      end
      context 'third page requested' do
        # thid page is results 20-29 if rows is set to 10
        let!(:solr_search) { SolrSearch.new(page: 3, results_per_page: 20) }

        it 'returns number of rows per page times the page number' do
          expect(solr_search.start).to eq(40)
        end
      end
    end
  end

  describe 'rows' do
    context 'where per page parameter is blank' do
      let!(:solr_search) { SolrSearch.new(results_per_page: nil) }
      it 'returns 20' do
        expect(solr_search.rows).to eq(20)
      end
    end

    context 'where per page parameter is not an integer' do
      let!(:solr_search) { SolrSearch.new(results_per_page: 'test') }
      it 'returns 20' do
        expect(solr_search.rows).to eq(20)
      end
    end

    context 'where per page parameter is 10' do
      let!(:solr_search) { SolrSearch.new(results_per_page: 10) }
      it 'returns 10' do
        expect(solr_search.rows).to eq(10)
      end
    end

    context 'where per page parameter is 20' do
      let!(:solr_search) { SolrSearch.new(results_per_page: 20) }
      it 'returns 20' do
        expect(solr_search.rows).to eq(20)
      end
    end

    context 'where per page parameter is 100' do
      let!(:solr_search) { SolrSearch.new(results_per_page: 100) }
      it 'returns 100' do
        expect(solr_search.rows).to eq(100)
      end
    end
  end

  describe 'search_filter' do
    context 'with a single filter' do
      let!(:solr_search) { SolrSearch.new(filter: { 'field_name' => ['test'] }) }

      it 'returns an array containing the tagged filter string' do
        expect(solr_search.search_filter).to eq(["{!tag=field_name}field_name:(test)"])
      end
    end
    context 'with multiple filters' do
      let!(:solr_search) { SolrSearch.new(filter: { "type_ses" => ["347163"], "subtype_ses" => ["363905"] }) }

      it 'returns an array of tagged filter strings' do
        expect(solr_search.search_filter).to eq(["{!tag=type_ses}type_ses:(347163)", "{!tag=subtype_ses}subtype_ses:(363905)"])
      end
    end
    context 'with multiple values for the same filter' do
      let!(:solr_search) { SolrSearch.new(filter: { "type_sesrollup" => ["347163", "363905"] }) }

      it 'returns an array containing the tagged filter string, with multiple values' do
        expect(solr_search.search_filter).to eq(["{!tag=type_sesrollup}type_sesrollup:(347163 363905)"])
      end
    end
  end

  describe 'search_query' do
    context 'with no query' do
      it 'returns nil' do
        expect(solr_search.search_query).to eq(nil)
      end
    end
    context 'with a filter' do
      let!(:solr_search) { SolrSearch.new(filter: { 'field_name' => ['test'] }) }

      it 'returns nil' do
        expect(solr_search.search_query).to eq(nil)
      end
    end
    context 'with a query' do
      let!(:solr_search) { SolrSearch.new(query: 'horse') }

      it 'returns the query' do
        expect(solr_search.search_query).to eq('horse')
      end
    end
  end

  describe 'expanded_query' do
    context 'with no query' do
      let!(:solr_search) { SolrSearch.new(query: '', filter: { "answeringMember_ses" => ["304301"] }, query_expander: expand_query_class) }
      let(:expand_query_class) { class_double(QueryExpander, new: expand_query_instance) }
      let(:expand_query_instance) { instance_double(QueryExpander) }

      it 'raises a QueryExpansionError' do
        expect { solr_search.expanded_query }.to raise_error(QueryExpansionError)
      end
    end

    context 'where query expansion fails' do
      let!(:solr_search) { SolrSearch.new(query: 'horse', filter: { "answeringMember_ses" => ["304301"] }, query_expander: expand_query_class) }

      it 'raises a QueryExpansionError' do
        expect(expand_query_instance).to receive(:expand_query).and_return('')
        expect { solr_search.expanded_query }.to raise_error(QueryExpansionError)
      end
    end

    context 'with a query' do
      let(:solr_search) { SolrSearch.new(query: 'horse', query_expander: expand_query_class) }
      let(:expand_query_instance) { instance_double(QueryExpander, expand_query: 'test') }

      it 'returns an expanded query' do
        # initialises QueryExpander with the search query
        expect(expand_query_class).to receive(:new).with('horse')

        # calls expand query on the instance of QueryExpander
        expect(expand_query_instance).to receive(:expand_query).and_return('expanded query string')

        # result is the response from expand query method
        expect(solr_search.expanded_query).to eq('expanded query string')
      end
    end
  end
end
