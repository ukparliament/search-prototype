# frozen_string_literal: true

##
# Query class for fetching a single Solr record using its object URI

class SolrQuery::Fetch < SolrQuery
  attr_reader :uri, :api_client, :api_error_handler

  def initialize(uri: nil, api_client: ApiClient::Post, api_error_handler: ApiErrorHandler)
    super(api_client: api_client, api_error_handler: api_error_handler)
    @uri = uri
  end

  ##
  # Initialise an instance of the API client with the uri, params & headers & request a response
  # Use error handler instance to check for errors (raises error or returns response)
  def data
    # set up request
    request = api_client.new(uri: build_uri, params: search_params, headers: request_headers)

    # make request & handle any errors in response
    response = api_error_handler.new(response: request.response).handle_errors

    process_response(response)
  end

  private

  def process_response(response)
    response.dig('response', 'docs').first
  end

  def search_params
    {
      "q": "uri:#{object_uri}"
    }
  end

end
