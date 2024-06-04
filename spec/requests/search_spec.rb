require 'rails_helper'

RSpec.describe 'Search', type: :request do
  describe 'GET /search' do

    context 'solr returns an error' do
      let!(:solr_search_instance) { SolrSearch.new(query: { "filter" => { "type_ses" => ["90996"] } }) }
      let!(:ses_lookup_instance) { SesLookup.new('test SES lookup input') }
      let!(:item1) { { 'type_ses' => [90996], 'title_t' => 'Test item 1', 'uri' => 'test_item_1_uri', 'all_ses' => [90996, 12345] } }
      let!(:item2) { { 'type_ses' => [90996], 'title_t' => 'Test item 2', 'uri' => 'test_item_2_uri', 'all_ses' => [90996, 56789] } }
      let!(:item3) { { 'type_ses' => [90996], 'title_t' => 'Test item 3', 'uri' => 'test_item_3_uri', 'all_ses' => [90996, 34567] } }
      let!(:test_search_response) { { 'response' => { 'start' => 0, 'docs' => [item1, item2, item3] }, 'facet_counts' => { 'facet_fields' => { 'type_ses' => [90996, 123, 90995, 234] } } } }

      it 'renders an error page' do
        allow_any_instance_of(SearchData).to receive(:solr_error?).and_return(true)
        allow(SolrSearch).to receive(:new).and_return(solr_search_instance)
        allow(solr_search_instance).to receive(:all_data).and_return(test_search_response)
        allow(SesLookup).to receive(:new).and_return(ses_lookup_instance)
        allow(ses_lookup_instance).to receive(:data).and_return('test ses response')
        allow(ses_lookup_instance).to receive(:hierarchy_data).and_return('test ses response')

        get '/search', params: { "filter" => { "type_ses" => ["90996"] } }
        expect(response).to have_http_status(:ok)
        expect(CGI::unescapeHTML(response.body)).to include('Something has gone wrong')
      end
    end

    context 'a search using filters' do
      let!(:solr_search_instance) { SolrSearch.new(query: { "filter" => { "type_ses" => ["90996"] } }) }
      let!(:ses_lookup_instance) { SesLookup.new([{ value: 12345 }, { value: 56789 }]) }
      let!(:item1) { { 'type_ses' => [90996], 'title_t' => 'Test item 1', 'uri' => 'test_item_1_uri', 'all_ses' => [90996, 12345] } }
      let!(:item2) { { 'type_ses' => [90996], 'title_t' => 'Test item 2', 'uri' => 'test_item_2_uri', 'all_ses' => [90996, 56789] } }
      let!(:item3) { { 'type_ses' => [90996], 'title_t' => 'Test item 3', 'uri' => 'test_item_3_uri', 'all_ses' => [90996, 34567] } }
      let!(:test_search_response) { { 'response' => { 'start' => 0, 'docs' => [item1, item2, item3] }, 'facet_counts' => { 'facet_fields' => { 'type_ses' => [90996, 123, 90995, 234] } } } }

      it 'returns http success' do
        allow(SolrSearch).to receive(:new).and_return(solr_search_instance)
        allow(solr_search_instance).to receive(:all_data).and_return(test_search_response)
        allow(SesLookup).to receive(:new).and_return(ses_lookup_instance)
        allow(ses_lookup_instance).to receive(:data).and_return('test ses response')
        allow(ses_lookup_instance).to receive(:hierarchy_data).and_return('test ses response')

        # a new instance of SolrSearch is created
        expect(SolrSearch).to receive(:new)

        # the results are retrieved from the search
        expect(solr_search_instance).to receive(:all_data)

        # SES lookup is still performed (without duplicates)
        # Any SES field in the facets are also included here
        expect(SesLookup).to receive(:new).with([{ value: [12345, 34567, 56789, 90995, 90996] }])

        # the SES results are retrieved
        expect(ses_lookup_instance).to receive(:data)

        get '/search', params: { "filter" => { "type_ses" => ["90996"] } }
        expect(response).to have_http_status(:ok)
      end

      it 'returns items found by search' do
        allow_any_instance_of(SolrSearch).to receive(:all_data).and_return(test_search_response)
        allow_any_instance_of(SesLookup).to receive(:data).and_return('test ses response')

        get '/search', params: { "filter" => { "type_ses" => ["90996"] } }
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.inner_html).to include("Parliamentary search - Search results")
        expect(response.parsed_body.inner_html).to include('Test item 1')
        expect(response.parsed_body.inner_html).to include('http://www.example.com/objects?object=test_item_1_uri')
        expect(response.parsed_body.inner_html).to include('Test item 2')
        expect(response.parsed_body.inner_html).to include('http://www.example.com/objects?object=test_item_2_uri')
        expect(response.parsed_body.inner_html).to include('Test item 3')
        expect(response.parsed_body.inner_html).to include('http://www.example.com/objects?object=test_item_3_uri')
      end
    end

    context 'a search using a query string' do
      let!(:solr_search_instance) { SolrSearch.new(query: { "query" => 'item 2' }) }
      let!(:ses_lookup_instance) { SesLookup.new([{ value: 12345 }, { value: 56789 }]) }
      let!(:item1) { { 'type_ses' => [90996], 'title_t' => 'Test item 1', 'uri' => 'test_item_1_uri', 'all_ses' => [90996, 12345] } }
      let!(:item2) { { 'type_ses' => [90996], 'title_t' => 'Test item 2', 'uri' => 'test_item_2_uri', 'all_ses' => [90996, 56789] } }
      let!(:item3) { { 'type_ses' => [90996], 'title_t' => 'Test item 3', 'uri' => 'test_item_3_uri', 'all_ses' => [90996, 34567] } }
      let!(:test_search_response) { { 'response' => { 'start' => 0, 'docs' => [item1, item2, item3] }, 'facet_counts' => { 'facet_fields' => { 'type_ses' => [90996, 123, 90995, 234] } } } }

      it 'returns http success' do
        allow(SolrSearch).to receive(:new).and_return(solr_search_instance)
        allow(solr_search_instance).to receive(:all_data).and_return(test_search_response)
        allow(SesLookup).to receive(:new).and_return(ses_lookup_instance)
        allow(ses_lookup_instance).to receive(:data).and_return('test ses response')
        allow(ses_lookup_instance).to receive(:hierarchy_data).and_return('test ses response')

        expect(SolrSearch).to receive(:new)
        expect(solr_search_instance).to receive(:all_data)

        # SES lookup is still performed (without duplicates)
        # Any SES field in the facets are also included here
        expect(SesLookup).to receive(:new).with([{ value: [12345, 34567, 56789, 90995, 90996] }])
        expect(ses_lookup_instance).to receive(:data)

        get '/search', params: { "query" => 'item 2' }
        expect(response).to have_http_status(:ok)
      end
    end
  end
end