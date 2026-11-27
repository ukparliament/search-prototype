# frozen_string_literal: true

##
# SES API query class
# Used for lookup queries
# Provide one or more SES IDs and receive a matching term
class SesQuery::Lookup < SesQuery

  ID_GROUP_SIZE = 250.freeze

  attr_reader :ses_ids

  def initialize(ses_ids: [], api_client: ApiClient::Get, api_error_handler: ApiErrorHandler)
    super(api_client: api_client, api_error_handler: api_error_handler)
    @ses_ids = ses_ids
  end

  def data
    return if ses_ids.blank?

    threads = ses_ids.each_slice(ID_GROUP_SIZE).map do |slice|
      Thread.new do
        request = api_client.new(uri: build_uri(slice), headers: request_headers)
        api_error_handler.new(response: request.response).handle_errors
      end
    end

    response = threads.flat_map { |r| r.value.dig('terms') }

    process_response(response)
  end

  private

  def process_response(response)
    # for returning all data in a structured format for further querying
    ret = {}

    if response.compact.blank?
      puts "SES returned no results for: #{ses_ids.inspect}" if Rails.env.development?
    else
      response.each do |term|
        ret[term.dig('term', 'id').to_i] = term.dig('term', 'name')

        # Scope note key is lower case in SES v5
        scope_note = term.dig("term", "metadata", "Scope note") || term.dig("term", "metadata", "scope note")
        ret["#{term['term']['id'].to_i}_scope_note"] = scope_note unless scope_note.blank?
      end
    end

    ret
  end

  def build_uri(lookup_ids)
    URI::HTTPS.build(
      host: common_api_host_path,
      path: ses_path,
      query: "tbdb=#{ses_tbdb}&template=service.json&expand_hierarchy=0&service=termlite&id=#{lookup_ids.join(',')}"
    )
  end
end