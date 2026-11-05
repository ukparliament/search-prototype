# frozen_string_literal: true

##
# Service class for querying the SES API
# Used via three subclasses: browse, lookup and search.
# API client dependency for generic API interactivity code

class SesQuery
  attr_reader :api_client, :api_error_handler

  SES_ID_GROUP_SIZE = 250.freeze

  def initialize(api_client: ApiClient::Get, api_error_handler: ApiErrorHandler)
    @api_client = api_client
    @api_error_handler = api_error_handler
  end

  private

  def common_api_host_path
    ENV["API_HOST"] || Rails.application.credentials.dig(Rails.env.to_sym, :api_host)
  end

  def api_subscription_key
    ENV["API_SUBSCRIPTION_KEY"] || Rails.application.credentials.dig(Rails.env.to_sym, :api_subscription_key)
  end

  def request_headers
    { 'Ocp-Apim-Subscription-Key' => api_subscription_key }
  end

  def lookup_ids
    # extract all sub arrays from the hashes
    return if input_data.blank?

    input_data.map { |h| h[:value] }.flatten.uniq.compact.sort
  end

  def lookup_id_groups
    # The SES API does not support POST, so we have to make multiple get requests
    return if input_data.blank?

    ret = []

    lookup_ids.each_slice(SES_ID_GROUP_SIZE) do |slice|
      ret << slice.join(',')
    end

    ret
  end

  def evaluated_responses
    # for each chunk, make a new request, then combine the results
    # returns a (flattened) array
    output = []
    threads = []

    start_time = Time.now

    lookup_id_groups.each do |id_group|
      # one request per group of IDs; one thread per request
      threads << Thread.new do
        puts "Begin thread" if Rails.env.development?

        # build uri
        uri = ses_term_service_uri(id_group)

        # fetch response
        response = api_response(uri)

        if response.has_key?('error')
          # if response is { "error" => {} }, return it
          output << response
        else
          # extract terms
          terms = response.dig('terms')
          # collate terms from all responses
          output << terms
        end
      end
    end

    # wait for all threads to have finished executing
    threads.each(&:join)
    puts "All requests completed in #{Time.now - start_time} seconds" if Rails.env.development?

    # flatten responses
    output.flatten
  end

  ##
  # Retrieve hierarchy data (172 results with CLASS="CTP")
  def evaluated_hierarchy_response
    caching_enabled = Rails.env.development? || Rails.env.test? ? false : true
    api_response(ses_browse_service_uri, caching_enabled)
  end

  def ses_tbdb
    ENV["SES_TBDB"] || Rails.application.credentials.dig(Rails.env.to_sym, :ses_api, :tbdb)
  end

  def ses_path
    ENV["SES_PATH"] || Rails.application.credentials.dig(Rails.env.to_sym, :ses_api, :path)
  end
end