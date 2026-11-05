# frozen_string_literal: true

##
# SES API query class
# Used for retrieving all class terms

class SesQuery::TypeHierarchy < SesQuery

  def initialize
    super
  end

  ##
  #
  def data
    # set up request
    request = api_client.new(uri: build_uri, headers: request_headers, cache_response: true)

    # make request & handle any errors in response
    # assign resulting hash to response
    response = api_error_handler.new(response: request.response).handle_errors

    process_response(response)
  end

  private

  def build_uri
    URI::HTTPS.build(
      host: common_api_host_path,
      path: ses_path,
      query: URI.encode_www_form(tbdb: ses_tbdb, template: 'service.json', service: 'allterms', expand_hierarchy: '1', filter: "CL=CTP")
    )
  end

  ##
  # Restructures SES response into type hierarchy
  # Accepts API responses (an array of hashes)
  # Each hash is the parsed response from individual lookups (one per [group_size] IDs)
  # the hashes contain a nested 'term' hash containing 'id' and 'name'
  # Returns a hash with keys constructed from the name and ID of the term
  def process_response(responses)
    ret = {}

    terms = responses.dig('terms')
    unless terms.compact.blank?
      terms.each do |term|
        new_key = []
        new_key << term.dig('term', 'id')&.to_i
        new_key << term.dig('term', 'name')
        ret[new_key] = term.dig('term', 'hierarchy')
      end
    end

    ret
  end
end