class SesLookup < ApiCall
  attr_reader :input_data

  def initialize(input_data)
    @input_data = input_data
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
      threads << Thread.new do
        puts "Begin thread" if Rails.env.development?

        # build uri
        uri = ses_term_service_uri(id_group)

        # fetch response
        response = api_response(uri)

        # extract terms
        terms = response.dig('terms')

        # collate terms from all responses
        output << terms
      end
    end

    # wait for all threads to have finished executing
    threads.each(&:join)
    puts "All requests completed in #{Time.now - start_time} seconds" if Rails.env.development?

    # flatten responses
    output.flatten
  end

  def evaluated_hierarchy_response
    api_response(ses_browse_service_uri, true)
  end

  def test_api_response
    start_time = Time.now
    uri = ses_term_service_uri("346696")
    response = api_response(uri)
    puts "Completed SES check in #{Time.now - start_time} seconds" if Rails.env.development?
    response
  end

  def data
    # for returning all data in a structured format for further querying
    return if input_data.blank?

    ret = {}
    responses = evaluated_responses

    # responses is an array of hashes
    # each hash is the parsed response from individual lookups (one per [group_size] IDs)
    # the hashes contain a nested 'term' hash containing 'id' and 'name'

    # If SES returns an error, we'll get an error key returned from evaluated_response
    return responses.first if responses.first&.has_key?(:error)

    # TODO: reduce data retrieved from SES if possible (API limitations - vendor input needed)

    unless responses.compact.blank?
      responses.each do |response|
        ret[response['term']['id'].to_i] = response['term']['name']
        ret["#{response['term']['id'].to_i}_scope_note"] = response['term']['metadata']['Scope note']
      end
    end
    ret
  end

  def extract_hierarchy_data
    # for returning all data in a structured format for further querying
    return if input_data.blank?

    ret = {}
    responses = evaluated_hierarchy_response

    # responses is an array of hashes
    # each hash is the parsed response from individual lookups (one per [group_size] IDs)
    # the hashes contain a nested 'term' hash containing 'id' and 'name'

    # If SES returns an error, we'll get an error key returned from evaluated_response
    return responses if responses.has_key?("error")

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

  def ses_base_url
    Rails.application.credentials.dig(Rails.env.to_sym, :ses_api, :endpoint)
  end

  def ses_term_service_uri(id_group_string)

    base_url = ses_base_url
    base_url = 'https://api.parliament.uk/ses/' if Rails.env.test?
    # using 'termlite' is faster for basic info required, but this is noted as being deprecated and due for
    # removal, at which point 'term' will have to be used instead
    build_uri("#{base_url}select.exe?TBDB=disp_taxonomy&TEMPLATE=service.json&expand_hierarchy=0&SERVICE=termlite&ID=#{id_group_string}")
  end

  def ses_browse_service_uri
    base_url = ses_base_url
    build_uri("#{base_url}select.exe?TBDB=disp_taxonomy&TEMPLATE=service.json&expand_hierarchy=1&SERVICE=allterms&CLASS=CTP")
  end

  private

  def group_size
    250
  end

  def api_response(uri, cached = false)
    raise 'Please stub this method to avoid HTTP requests in test environment' if Rails.env.test?

    raw_response = cached ? api_cached_get_request(uri) : api_get_request(uri)
    raise "Nil response from API" if raw_response.nil?

    begin
      JSON.parse(raw_response)
    rescue JSON::ParserError
      # contrary to SES API documentation, errors seem to be returned as XML regardless of specified TEMPLATE
      evaluated_as_xml = Hash.from_xml(raw_response)
      puts "Error: #{evaluated_as_xml}" if Rails.env.development?
    end
  end
end