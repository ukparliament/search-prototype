class SesLookup < ApiClient
  attr_reader :input_data

  def initialize(input_data)
    @input_data = input_data
  end

  def data
    # for returning all data in a structured format for further querying
    return if input_data.blank?

    ret = {}
    responses = evaluated_responses

    if responses.compact.blank?
      raise ExternalServiceNotFound
    else
      responses.each do |response|
        raise_external_service_error(response)

        ret[response['term']['id'].to_i] = response['term']['name']
        ret["#{response['term']['id'].to_i}_scope_note"] = response['term']['metadata']['Scope note'] unless response['term']['metadata']['Scope note'].blank?
      end
    end
    ret
  end

  def extract_hierarchy_data
    # TODO: extract to its own class?
    # for returning all data in a structured format for further querying
    return if input_data.blank?

    ret = {}
    responses = evaluated_hierarchy_response

    # responses is an array of hashes
    # each hash is the parsed response from individual lookups (one per [group_size] IDs)
    # the hashes contain a nested 'term' hash containing 'id' and 'name'

    # If SES returns an error, we'll get an error key returned from evaluated_response
    raise_external_service_error(responses)

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

  private

  def lookup_ids
    # extract all sub arrays from the hashes
    return if input_data.blank?

    input_data.map { |h| h[:value] }.flatten.uniq.compact.sort
  end

  def lookup_id_groups
    # The SES API does not support POST, so we have to make multiple get requests
    return if input_data.blank?

    ret = []

    lookup_ids.each_slice(group_size) do |slice|
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
      # TODO: look into a more efficient approach to thread management
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

  def evaluated_hierarchy_response
    caching_enabled = Rails.env.development? ? false : true
    api_response(ses_browse_service_uri, caching_enabled)
  end

  def ses_term_service_uri(id_group_string)
    # Due to limitations of the SES API we can't encode the query string here - it doesn't like the commas
    uri = URI::HTTPS.build(
      host: Rails.application.credentials.dig(Rails.env.to_sym, :api_host),
      path: Rails.application.credentials.dig(Rails.env.to_sym, :ses_api, :path),
      query: "TBDB=disp_taxonomy&TEMPLATE=service.json&expand_hierarchy=0&SERVICE=termlite&ID=#{id_group_string}"
    )
  end

  def ses_browse_service_uri
    URI::HTTPS.build(
      host: Rails.application.credentials.dig(Rails.env.to_sym, :api_host),
      path: Rails.application.credentials.dig(Rails.env.to_sym, :ses_api, :path),
      query: URI.encode_www_form(TBDB: 'disp_taxonomy', TEMPLATE: 'service.json', SERVICE: 'allterms', expand_hierarchy: '1', CLASS: 'CTP')
    )
  end

  def group_size
    250
  end

  def api_response(uri, cached = false)
    raw_response = api_get_request(uri, cached)
    raise ExternalServiceNotFound if raw_response.nil?

    begin
      JSON.parse(raw_response)
    rescue JSON::ParserError
      Hash.from_xml(raw_response)
    end
  end

  def api_get_request(uri, cached = false)
    raise 'Please stub this method to avoid HTTP requests in test environment' if Rails.env.test?

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'

    # set up the request object
    request = Net::HTTP::Get.new(uri)
    request_headers.each { |k, v| request[k] = v }

    # make the request with or without caching
    if cached
      Rails.cache.fetch(uri, expires_in: 2.hours) do
        http.request(request).body
      end
    else
      http.request(request).body
    end
  end

end