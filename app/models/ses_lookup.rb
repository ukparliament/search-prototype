class SesLookup
  require 'open-uri'
  require 'net/http'

  attr_reader :lookup_ids

  BASE_API_URI = "https://api.parliament.uk/ses/"

  def initialize(ses_ids)
    @lookup_ids = ses_ids
  end

  def lookup_string
    lookup_ids.uniq.compact.flatten.join(',')
  end

  def data
    # for returning all data in a structured format for further querying
    return unless lookup_ids.any?

    ret = {}
    evaluated_response['terms'].each do |term|
      ret[term['term']['id'].to_i] = term['term']['name']
    end
    ret
  end

  def ruby_uri
    build_uri("#{BASE_API_URI}select.exe?TBDB=disp_taxonomy&TEMPLATE=service.json&SERVICE=term&ID=#{lookup_string}")
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