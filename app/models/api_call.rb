class ApiCall
  require 'open-uri'
  require 'net/http'

  attr_reader :object_uri

  BASE_API_URI = "https://api.parliament.uk/new-solr/"

  def initialize(params)
    @object_uri = params[:object_uri]
  end

  private

  def response_body
    get_api_response(ruby_uri)
  end

  def evaluated_response
    JSON.parse(response_body)
  end

  def build_uri(url)
    URI.parse(url)
  end

  def get_api_response(uri)
    Net::HTTP.get(uri, request_headers)
  end

  def api_subscription_key
    Rails.application.credentials.dig(:solr_api, :subscription_key)
  end

  def request_headers
    { 'Ocp-Apim-Subscription-Key' => api_subscription_key }
  end
end