require 'rails_helper'

RSpec.describe 'Search', type: :request do
  describe 'GET /search' do
    let!(:ses_query_lookup_instance) { SesQuery::Lookup.new(ses_ids: [12345, 56789]) }
    let!(:item1_initial) { { 'type_ses' => [90996], 'uri' => 'QZH4EFc_uri' } }
    let!(:item2_initial) { { 'type_ses' => [90996], 'uri' => 'SL9RT6y_uri' } }
    let!(:item3_initial) { { 'type_ses' => [90996], 'uri' => 'BZ34eDD_uri' } }
    let!(:initial_search_data) { { search_parameters: { "query" => 'item 2' }, data: { 'response' => { 'start' => 0, 'numFound' => 3, 'docs' => [item1_initial, item2_initial, item3_initial] }, 'facets' => { "count" => 5, 'type_sesrollup' => { "buckets" => [{ "val" => 90996, "count" => 123 }, { "val" => 90995, "count" => 234 }] } } } } }
    let!(:item1) { Edm.new({ 'type_ses' => [90996], 'title_t' => 'QZH4EFc', 'uri' => 'QZH4EFc_uri', 'all_ses' => [90996, 12345] }) }
    let!(:item2) { Edm.new({ 'type_ses' => [90996], 'title_t' => 'SL9RT6y', 'uri' => 'SL9RT6y_uri', 'all_ses' => [90996, 56789] }) }
    let!(:item3) { Edm.new({ 'type_ses' => [90996], 'title_t' => 'BZ34eDD', 'uri' => 'BZ34eDD_uri', 'all_ses' => [90996, 34567] }) }
    let!(:solr_query_lookup_instance) { SolrQuery::Lookup.new(uris: ['QZH4EFc_uri', 'SL9RT6y_uri', 'BZ34eDD_uri', 'BZ34eDD_uri'], solr_fields: Edm.search_result_solr_fields) }
    let!(:secondary_query_response) { [item1, item2, item3] }
    let!(:associated_objects_instance) { AssociatedObjectsForSearchResults.new([item1, item2, item3]) }
    let!(:associated_objects_response) { { object_data: { 'QZH4EFc_uri' => item1, 'SL9RT6y_uri' => item2, 'BZ34eDD_uri' => item3 }, ses_ids: [12345, 56789, 55555] } }
    let!(:test_api_client_class) { class_double(ApiClient::Post, new: test_api_client_instance) }
    let!(:test_api_client_instance) { instance_double(ApiClient::Post, response: 'test api response') }
    let!(:example_object) { Edm.new({ [92424, "Personal statements"] => [{ "typeId" => "1", "qty" => "1", "name" => "Broader Term", "abbr" => "BT", "fields" => [{ "field" => { "name" => "Oral statements", "id" => "350073", "zid" => "52566919", "class" => "CTP", "freq" => "0", "facets" => [{ "id" => "346696", "name" => "Content type" }] } }] }] }) }
    let!(:search_data_instance) { instance_double(SearchData, search: initial_search_data, hierarchy_builder: hierarchy_builder_instance, solr_query: solr_query_lookup_instance, object_data: secondary_query_response, facet_ses_ids: [], filter_count: 0, facets: []) }
    let!(:hierarchy_builder_instance) { instance_double(HierarchyBuilder, data: 'hierarchy_data_response', formatted_ses_data: { '12345' => 'name' }) }

    before do
      allow(SolrQuery::Search).to receive(:new).and_return(solr_search_instance)
      allow(solr_search_instance).to receive(:data).and_return(initial_search_data)
      allow(SolrQuery::Lookup).to receive(:new).and_return(solr_query_lookup_instance)
      allow(solr_query_lookup_instance).to receive(:data).and_return(secondary_query_response)
      allow(AssociatedObjectsForSearchResults).to receive(:new).and_return(associated_objects_instance)
      allow(associated_objects_instance).to receive(:data).and_return(associated_objects_response)
      allow(SesQuery::Lookup).to receive(:new).and_return(ses_query_lookup_instance)
      allow(ses_query_lookup_instance).to receive(:data).and_return({ 45678 => 'string', 67890 => 'string' })
      allow(ses_query_lookup_instance).to receive(:process_response).and_return([example_object])
      allow(SearchData).to receive(:new).and_return(search_data_instance)
    end

    context 'a search that returns an unsupported object type' do
      let!(:solr_search_instance) { SolrQuery::Search.new(query: "test", api_client: test_api_client_class) }
      # overwrite item1 in initial setup with an unsupported object type instead
      let!(:item1) { NotSupported.new({ 'type_ses' => [12345], 'title_t' => 'QZH4EFc', 'uri' => 'QZH4EFc_uri', 'all_ses' => [90996, 12345] }) }

      before do
        expect(search_data_instance).to receive(:type_facets)
        expect(search_data_instance).to receive(:hierarchy_data)
        expect(search_data_instance).to receive(:hierarchy_ses_data)
        expect(search_data_instance).to receive(:query).exactly(9).times
        expect(search_data_instance).to receive(:show_detailed).exactly(6).times
        expect(search_data_instance).to receive(:show_detailed?)
        expect(search_data_instance).to receive(:sort).exactly(7).times
        expect(search_data_instance).to receive(:current_page).exactly(2).times
        expect(search_data_instance).to receive(:results_per_page).exactly(7).times
        expect(search_data_instance).to receive(:start)
        expect(search_data_instance).to receive(:end)
        expect(search_data_instance).to receive(:number_of_results).exactly(2).times
        expect(search_data_instance).to receive(:query_time)
        expect(search_data_instance).to receive(:query_as_submitted)
        expect(search_data_instance).to receive(:filter).exactly(6).times
        expect(search_data_instance).to receive(:filter_count)
        expect(search_data_instance).to receive(:facets)
        expect(search_data_instance).to receive(:facet_ses_ids)
        expect(search_data_instance).to receive(:expanded_types)
        expect(search_data_instance).to receive(:expanded_types_string).exactly(6).times
      end

      it 'still returns http success' do
        get '/search', params: { query: "test" }
        expect(response).to have_http_status(:ok)
      end

      it 'quietly removes unsupported objects' do
        get '/search', params: { "query" => "test" }
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.inner_html).to include("Search Results - Parliamentary Search")
        expect(response.parsed_body.inner_html).not_to include('QZH4EFc')
        expect(response.parsed_body.inner_html).not_to include('http://www.example.com/objects?object=QZH4EFc_uri')
        expect(response.parsed_body.inner_html).to include('SL9RT6y')
        expect(response.parsed_body.inner_html).to include('http://www.example.com/objects?object=SL9RT6y_uri')
        expect(response.parsed_body.inner_html).to include('BZ34eDD')
        expect(response.parsed_body.inner_html).to include('http://www.example.com/objects?object=BZ34eDD_uri')
      end
    end

    context 'a search using filters' do
      let!(:solr_search_instance) { SolrQuery::Search.new(query: { "filter" => { "type_ses" => ["90996"] } }) }

      before do
        expect(search_data_instance).to receive(:type_facets)
        expect(search_data_instance).to receive(:hierarchy_data)
        expect(search_data_instance).to receive(:hierarchy_ses_data)
        expect(search_data_instance).to receive(:query).exactly(9).times
        expect(search_data_instance).to receive(:show_detailed).exactly(6).times
        expect(search_data_instance).to receive(:show_detailed?)
        expect(search_data_instance).to receive(:sort).exactly(7).times
        expect(search_data_instance).to receive(:current_page).exactly(2).times
        expect(search_data_instance).to receive(:results_per_page).exactly(7).times
        expect(search_data_instance).to receive(:start)
        expect(search_data_instance).to receive(:end)
        expect(search_data_instance).to receive(:number_of_results).exactly(2).times
        expect(search_data_instance).to receive(:query_time)
        expect(search_data_instance).to receive(:query_as_submitted)
        expect(search_data_instance).to receive(:filter).exactly(6).times
        expect(search_data_instance).to receive(:filter_count)
        expect(search_data_instance).to receive(:facets)
        expect(search_data_instance).to receive(:facet_ses_ids)
        expect(search_data_instance).to receive(:expanded_types)
        expect(search_data_instance).to receive(:expanded_types_string).exactly(6).times
      end

      it 'returns http success' do
        get '/search', params: { "query" => "test", "filter" => { "type_ses" => ["90996"] } }
        expect(response).to have_http_status(:ok)
      end

      it 'returns items found by search' do
        get '/search', params: { "query" => "test", "filter" => { "type_ses" => ["90996"] } }
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.inner_html).to include("Search Results - Parliamentary Search")
        expect(response.parsed_body.inner_html).to include('QZH4EFc')
        expect(response.parsed_body.inner_html).to include('http://www.example.com/objects?object=QZH4EFc_uri')
        expect(response.parsed_body.inner_html).to include('SL9RT6y')
        expect(response.parsed_body.inner_html).to include('http://www.example.com/objects?object=SL9RT6y_uri')
        expect(response.parsed_body.inner_html).to include('BZ34eDD')
        expect(response.parsed_body.inner_html).to include('http://www.example.com/objects?object=BZ34eDD_uri')
      end
    end

    context 'a search for an empty string' do
      let!(:solr_search_instance) { SolrQuery::Search.new(query: { "query" => '' }) }

      it 'redirects to home' do
        # note that this is only seen in practice where someone submits an empty query via the url, as the search
        # fields have the 'required' attribute preventing form submission through the UI
        get '/search', params: { "query" => '' }
        expect(response).to redirect_to(home_path)
      end
    end

    context 'a search using a query string' do
      let!(:solr_search_instance) { SolrQuery::Search.new(query: { "query" => 'BZ34eDD' }) }

      before do
        expect(search_data_instance).to receive(:type_facets)
        expect(search_data_instance).to receive(:hierarchy_data)
        expect(search_data_instance).to receive(:hierarchy_ses_data)
        expect(search_data_instance).to receive(:query).exactly(9).times
        expect(search_data_instance).to receive(:show_detailed).exactly(6).times
        expect(search_data_instance).to receive(:show_detailed?)
        expect(search_data_instance).to receive(:sort).exactly(7).times
        expect(search_data_instance).to receive(:current_page).exactly(2).times
        expect(search_data_instance).to receive(:results_per_page).exactly(7).times
        expect(search_data_instance).to receive(:start)
        expect(search_data_instance).to receive(:end)
        expect(search_data_instance).to receive(:number_of_results).exactly(2).times
        expect(search_data_instance).to receive(:query_time)
        expect(search_data_instance).to receive(:query_as_submitted)
        expect(search_data_instance).to receive(:filter).exactly(6).times
        expect(search_data_instance).to receive(:filter_count)
        expect(search_data_instance).to receive(:facets)
        expect(search_data_instance).to receive(:facet_ses_ids)
        expect(search_data_instance).to receive(:expanded_types)
        expect(search_data_instance).to receive(:expanded_types_string).exactly(6).times
      end

      it 'returns http success' do
        get '/search', params: { "query" => 'Test search string' }
        expect(response).to have_http_status(:ok)
      end

      it 'returns items found by search' do
        get '/search', params: { "query" => 'Test search string' }
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.inner_html).to include("Search Results - Parliamentary Search")
        expect(response.parsed_body.inner_html).to include('QZH4EFc')
        expect(response.parsed_body.inner_html).to include('http://www.example.com/objects?object=QZH4EFc_uri')
        expect(response.parsed_body.inner_html).to include('SL9RT6y')
        expect(response.parsed_body.inner_html).to include('http://www.example.com/objects?object=SL9RT6y_uri')
        expect(response.parsed_body.inner_html).to include('BZ34eDD')
        expect(response.parsed_body.inner_html).to include('http://www.example.com/objects?object=BZ34eDD_uri')
      end
    end
  end
end