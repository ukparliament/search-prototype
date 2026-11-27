# frozen_string_literal: true

##
# SES API query class
# Used for performing term searches
# Provide a search string (term) and receive matching terms
class SesQuery::Search < SesQuery

  attr_reader :term, :api_client, :include_topics, :exact_match

  def initialize(term: nil, include_topics: false, exact_match: false, api_client: ApiClient::Get,
                 api_error_handler: ApiErrorHandler)
    super(api_client: api_client, api_error_handler: api_error_handler)
    @term = term
    @include_topics = include_topics
    @exact_match = exact_match
  end

  ##
  # Returns query expansion data from SES as an array, which may contain one or more terms in the form of a hash:
  # {
  #   equivalent_terms: ['equivalent term 1', 'equivalent term 2', '...'],
  #   preferred_term_id: '23456',
  #   preferred_term: 'preferred term'
  # }
  #
  # Name values under 'equivalence' are extracted into the equivalent_terms array. The preferred term name and
  # SES ID are assigned :preferred_term_id and :preferred_term respectively.
  #
  # Terms with the 'TPG' (topic) class are excluded by default, but can be included with include_topics: true.
  def data
    return if term.blank?

    # set up request
    request = api_client.new(uri: build_uri, headers: request_headers)

    # make request & handle any errors in response
    # assign resulting hash to response
    response = api_error_handler.new(response: request.response).handle_errors

    process_response(response)
  end

  private

  def process_response(response)
    # Extract terms (and original query) from response
    # Query string moves from query (v3) to mapping (v5)
    query_string = response.dig("parameters").has_key?("query") ? response["parameters"]["query"].downcase : response["parameters"]["mapping"].downcase
    terms = response.dig("terms")

    SesDataProcessor.new(terms: terms,
                         query_string: query_string,
                         query_string_processor: QueryStringProcessor,
                         exact_match_required: exact_match,
                         include_topics: include_topics).process_terms
  end

  def build_uri
    URI::HTTPS.build(host: common_api_host_path, path: ses_path,
                     query: URI.encode_www_form(tbdb: ses_tbdb,
                                                service: 'search',
                                                template: 'service.json',
                                                query: term)
    )
  end
end
