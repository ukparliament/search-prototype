class ApiCall
  require 'open-uri'
  require 'net/http'

  attr_reader :object_uri

  BASE_API_URL = "https://api.parliament.uk/new-solr/"

  def initialize(params)
    @object_uri = params[:object_uri]
  end

  def object_data
    all_data['docs']
  end

  def all_data
    response = evaluated_response
    return response if response['statusCode'] == 500

    response['response']
  end

  private

  def response_body
    raise 'Please stub this method to avoid HTTP requests in test environment' if Rails.env.test?

    get_api_response(ruby_uri)
  end

  def evaluated_response
    JSON.parse(response_body)
  end

  def build_uri(url)
    URI.parse(url)
  end

  def get_api_response(uri)
    puts "Get request from #{self.class.name}: #{uri}"
    Net::HTTP.get(uri, request_headers)
  end

  def api_subscription_key
    Rails.application.credentials.dig(:solr_api, :subscription_key)
  end

  def request_headers
    { 'Ocp-Apim-Subscription-Key' => api_subscription_key }
  end
end