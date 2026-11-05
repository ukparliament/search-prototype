##
# Query class for Solr API
class SolrQuery
  attr_reader :api_client, :api_error_handler

  def initialize(api_client: ApiClient::Post, api_error_handler: ApiErrorHandler)
    @api_client = api_client
    @api_error_handler = api_error_handler
  end

  private

  def build_uri
    URI::HTTPS.build(host: common_api_host_path, path: solr_api_path)
  end

  ##
  # Solr API path component
  def solr_api_path
    ENV["SOLR_API_PATH"] || Rails.application.credentials.dig(Rails.env.to_sym, :solr_api, :path)
  end

  ##
  # API root path
  def common_api_host_path
    ENV["API_HOST"] || Rails.application.credentials.dig(Rails.env.to_sym, :api_host)
  end

  ##
  # Key required for API auth
  def api_subscription_key
    ENV["API_SUBSCRIPTION_KEY"] || Rails.application.credentials.dig(Rails.env.to_sym, :api_subscription_key)
  end

  ##
  # Constructs request header hash containing subscription key for API
  def request_headers
    { 'Ocp-Apim-Subscription-Key' => api_subscription_key }
  end
end