class SesLookup < ApiCall
  attr_reader :input_data

  BASE_API_URL = "https://api.parliament.uk/ses/"

  # Note that this class has been refactored to operate on the 'standard data structure' (one or more hashes
  # of value and field_name) used elsewhere in the application:
  # [{value: w, field_name: 'x'}, { value: 'y', field_name: 'z'}...]

  def initialize(input_data)
    @input_data = input_data
  end

  def lookup_ids
    # extract all of the sub arrays from the hashes
    return if input_data.blank?

    input_data.map { |h| h[:value] }.flatten.uniq.compact
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
    lookup_id_groups.each do |id_group|

      begin
        response = JSON.parse(api_response(id_group))
      rescue JSON::ParserError
        # if SES fails it returns an error as XML
        response = Hash.from_xml(api_response(id_group))
        return [{ error: response }]
      end

      output << response['terms']
    end

    output.flatten
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
    return responses.first if responses.first.has_key?(:error)

    unless responses.compact.blank?
      responses.each do |response|
        ret[response['term']['id'].to_i] = response['term']['name']
      end
    end
    ret
  end

  def ruby_uri(id_group_string)
    build_uri("#{BASE_API_URL}select.exe?TBDB=disp_taxonomy&TEMPLATE=service.json&SERVICE=term&ID=#{id_group_string}")
  end

  private

  def group_size
    250
  end

  def api_response(id_group_string)
    raise 'Please stub this method to avoid HTTP requests in test environment' if Rails.env.test?

    api_get_request(ruby_uri(id_group_string))
  end
end