class SesQuery < SesLookup

  attr_reader :exact_match

  def initialize(input_data, exact_match: false)
    super(input_data)
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
  # Terms with the 'TPG' (topic) class are excluded.
  def data
    return if input_data.blank?

    # get parsed response
    response = evaluated_response

    # If the response is an error, raise it
    raise_external_service_error(response)

    # Extract terms (and original query) from response
    # Query string moves from query (v3) to mapping (v5)
    query_string = response.dig("parameters").has_key?("query") ? response["parameters"]["query"].downcase : response["parameters"]["mapping"].downcase
    terms = response.dig("terms")

    SesDataProcessor.new(terms: terms,
                         query_string: query_string,
                         query_string_processor: QueryStringProcessor,
                         exact_match_required: exact_match).process_terms
  end

  private

  def evaluated_response
    api_response(ses_search_uri, false)
  end

  def ses_search_uri
    URI::HTTPS.build(host: common_api_host_path, path: ses_path,
                     query: URI.encode_www_form(tbdb: ses_tbdb,
                                                service: 'search',
                                                template: 'service.json',
                                                query: term)
    )
  end

  def term
    return if input_data.blank?

    input_data[:value]
  end
end