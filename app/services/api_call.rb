class ApiCall
  require 'open-uri'
  require 'net/http'

  attr_reader :object_uri

  def initialize(params)
    @object_uri = params[:object_uri]
  end

  def object_data
    all_data['response']['docs']&.reject { |h| h.dig('type_ses').blank? }
  end

  def all_data
    # get Solr response as JSON
    response = evaluated_response

    # check for errors from Solr
    return response['error'] if response.has_key?('error')

    # otherwise return response JSON
    response
  end

  private

  ##
  # Processes response from API
  # - Gets response from POST method
  # - Force UTF-8 encoding on response body
  # - Parse body as JSON
  def evaluated_response
    # start timer
    start_time = Time.now

    # call request method, passing in search parameters
    response = api_post_request(search_params)

    # stop timer & report time taken
    puts "Received Solr response in #{Time.now - start_time} seconds" if Rails.env.development?

    JSON.parse(response.force_encoding('UTF-8'))
  end

  ##
  # Establish HTTP & request objects, then make the request (Net::HTTP)
  # Stub response from this method when testing, will error to avoid any test environment requests
  def api_post_request(query)
    raise 'Please stub this method to avoid HTTP requests in test environment' if Rails.env.test?

    uri = api_endpoint_uri
    headers = request_headers

    puts "POST request from #{self.class.name}: #{uri} with data: #{query} and headers: #{headers}" if Rails.env.development?

    # set up HTTP instance
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'

    # set up the request object
    request = Net::HTTP::Post.new(uri)
    request.set_form_data(query)
    headers.each { |k, v| request[k] = v }

    # make the request
    response = http.request(request)

    response.body
  end

  def api_endpoint_uri
    # fetch the Solr url string from credentials
    api_endpoint = Rails.application.credentials.dig(Rails.env.to_sym, :solr_api, :endpoint)
    # create a uri object from the string
    URI(api_endpoint).dup
  end

  def api_subscription_key
    Rails.application.credentials.dig(Rails.env.to_sym, :solr_api, :subscription_key)
  end

  def request_headers
    { 'Ocp-Apim-Subscription-Key' => api_subscription_key }
  end
end