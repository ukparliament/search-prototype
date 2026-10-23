require 'rails_helper'
require 'rss'

RSpec.describe 'Search', type: :request do
  describe 'GET /search' do
    let!(:ses_lookup_instance) { SesLookup.new([{ value: 12345 }, { value: 56789 }]) }
    let!(:item1_initial) { { 'type_ses' => [90996], 'uri' => 'QZH4EFc_uri' } }
    let!(:item2_initial) { { 'type_ses' => [90996], 'uri' => 'SL9RT6y_uri' } }
    let!(:item3_initial) { { 'type_ses' => [90996], 'uri' => 'BZ34eDD_uri' } }
    let!(:initial_search_data) { { search_parameters: { query: 'item 2' }, data: { 'response' => { 'start' => 0, 'numFound' => 3, 'docs' => [item1_initial, item2_initial, item3_initial] }, 'facets' => { "count" => 5, 'type_sesrollup' => { "buckets" => [{ "val" => 90996, "count" => 123 }, { "val" => 90995, "count" => 234 }] } } } } }
    let!(:item1) { { 'type_ses' => [90996], 'title_t' => 'QZH4EFc', 'uri' => 'QZH4EFc_uri', 'all_ses' => [90996, 12345], 'date_dt' => "2019-10-10T00:00:00Z", 'externalLocation_uri' => ['www.example.com'] } }
    let!(:item2) { { 'type_ses' => [90996], 'title_t' => 'SL9RT6y', 'uri' => 'SL9RT6y_uri', 'all_ses' => [90996, 56789], 'date_dt' => "2019-10-10T00:00:00Z", 'externalLocation_uri' => ['www.example.com'] } }
    let!(:item3) { { 'type_ses' => [90996], 'title_t' => 'BZ34eDD', 'uri' => 'BZ34eDD_uri', 'all_ses' => [90996, 34567], 'date_dt' => "2019-10-10T00:00:00Z", 'externalLocation_uri' => ['www.example.com'] } }
    let!(:solr_multi_query_instance) { SolrMultiQuery.new({ object_uris: ['QZH4EFc_uri', 'SL9RT6y_uri', 'BZ34eDD_uri', 'BZ34eDD_uri'], solr_fields: Edm.search_result_solr_fields }) }
    let!(:secondary_query_response) { [item1, item2, item3] }
    let!(:associated_objects_instance) { AssociatedObjectsForSearchResults.new([item1, item2, item3]) }
    let!(:associated_objects_response) { { object_data: { 'QZH4EFc_uri' => item1, 'SL9RT6y_uri' => item2, 'BZ34eDD_uri' => item3 }, ses_ids: [12345, 56789, 55555] } }

    before do
      allow(SolrSearch).to receive(:new).and_return(solr_search_instance)
      allow(solr_search_instance).to receive(:data).and_return(initial_search_data)
      allow(SolrMultiQuery).to receive(:new).and_return(solr_multi_query_instance)
      allow(solr_multi_query_instance).to receive(:object_data).and_return(secondary_query_response)

      allow(AssociatedObjectsForSearchResults).to receive(:new).and_return(associated_objects_instance)
      allow(associated_objects_instance).to receive(:data).and_return(associated_objects_response)
      allow(SesLookup).to receive(:new).and_return(ses_lookup_instance)
      allow(ses_lookup_instance).to receive(:data).and_return({ 45678 => 'string', 67890 => 'string' })
      allow(ses_lookup_instance).to receive(:extract_hierarchy_data).and_return({ [92424, "Personal statements"] => [{ "typeId" => "1", "qty" => "1", "name" => "Broader Term", "abbr" => "BT", "fields" => [{ "field" => { "name" => "Oral statements", "id" => "350073", "zid" => "52566919", "class" => "CTP", "freq" => "0", "facets" => [{ "id" => "346696", "name" => "Content type" }] } }] }] })
    end

    context 'a search that returns an unsupported object type' do
      let!(:solr_search_instance) { SolrSearch.new(query: "test") }
      let!(:item1) { { 'type_ses' => [12345], 'title_t' => 'QZH4EFc', 'uri' => 'QZH4EFc_uri', 'all_ses' => [90996, 12345] } }

      it 'still returns http success' do
        get '/search', params: { "query" => "test" }
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
      let!(:solr_search_instance) { SolrSearch.new(query: { "filter" => { "type_ses" => ["90996"] } }) }

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

    context 'a request for RSS' do
      let!(:solr_search_instance) { SolrSearch.new(query: "item 2", filter: { "type_ses" => ["90996"] }) }

      it 'returns http success' do
        get '/search.rss?query=item+2&filter%5Btype_ses%5D%5B%5D=90996'
        expect(response).to have_http_status(:ok)
      end

      it 'returns RSS XML' do
        get '/search.rss?query=item+2&filter%5Btype_ses%5D%5B%5D=90996'
        expect(response.media_type).to eq('application/rss+xml')
      end

      it 'returns a valid RSS feed' do
        get '/search.rss?query=item+2&filter%5Btype_ses%5D%5B%5D=90996'

        feed = RSS::Parser.parse(response.body)

        expect(feed.version).to eq('1.0')
        expect(feed.rss_version).to eq('2.0')
        expect(feed.channel.title).to eq("Search Results for item 2")
        expect(feed.channel.description).to eq("Results from Parliamentary Search for the query: item 2")
        expect(feed.channel.link).to eq("http://www.example.com/search?query=item+2&results_per_page=20")
        expect(feed.channel.copyright).to eq("https://www.parliament.uk/site-information/copyright-parliament/open-parliament-licence/")
        expect(feed.channel.language).to eq('en-uk')
        expect(feed.channel.pubDate).to eq(Date.parse('2019-10-10').rfc822)
        expect(feed.items.size).to eq(3)
        expect(feed.items.first.guid.content).to eq("QZH4EFc_uri")
        expect(feed.items.first.title).to eq("QZH4EFc")
        expect(feed.items.first.link).to eq("www.example.com")
        expect(feed.items.first.pubDate).to eq(Date.parse('2019-10-10').rfc822)
        expect(feed.items.first.description).to eq("Unknown, on , in the")
      end
    end

    context 'a search for an empty string' do
      let!(:solr_search_instance) { SolrSearch.new(query: { "query" => '' }) }

      it 'redirects to home' do
        # note that this is only seen in practice where someone submits an empty query via the url, as the search
        # fields have the 'required' attribute preventing form submission through the UI
        get '/search', params: { "query" => '' }
        expect(response).to redirect_to(home_path)
      end
    end

    context 'a search using a query string' do
      let!(:solr_search_instance) { SolrSearch.new(query: { "query" => 'BZ34eDD' }) }

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