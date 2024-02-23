class ApiCall
  require 'open-uri'
  require 'net/http'

  attr_reader :object_uri

  BASE_API_URL = "https://api.parliament.uk/new-solr/select?"

  def initialize(params)
    @object_uri = params[:object_uri]
  end

  def object_data
    all_data['docs']
  end

  def all_data
    response = evaluated_response
    return response if response['statusCode']

    response['response']
  end

  private

  def api_response
    raise 'Please stub this method to avoid HTTP requests in test environment' if Rails.env.test?

    api_post_request(search_params)
  end

  def evaluated_response
    JSON.parse(api_response.body)
  end

  def build_uri(url)
    URI.parse(url)
  end

  def api_post_request(params)
    _uri = URI(BASE_API_URL).dup
    data = URI.encode_www_form(params)
    puts "POST request from #{self.class.name}: #{_uri} with data: #{params} encoded as: #{data}"

    Net::HTTP.post(_uri, data, request_headers)
  end

  def api_get_request(uri)
    puts "GET request from #{self.class.name}: #{uri}"
    Net::HTTP.get(uri, request_headers)
  end

  def api_subscription_key
    Rails.application.credentials.dig(:solr_api, :subscription_key)
  end

  def request_headers
    { 'Ocp-Apim-Subscription-Key' => api_subscription_key }
  end
end