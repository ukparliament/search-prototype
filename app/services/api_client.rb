class ApiClient
  require 'open-uri'
  require 'net/http'

  attr_reader :uri, :params, :headers, :cache_response

  def initialize(uri:, params: {}, headers:, cache_response: false)
    @uri = uri
    @params = params
    @headers = headers
    @cache_response = cache_response
  end

  def response
    http_response = request

    if http_response.is_a?(Net::HTTPSuccess)
      parse_response_body(http_response)
    else
      ExternalServiceError.new(status: http_response.code.to_i, body: http_response.body)
    end
  end

  ##
  # Method to parse result of a request
  # Supports JSON, XML or HTML responses
  # Returns Ruby hash containing the body of the response
  # Where response is nil or of an unsupported content type, returns a Ruby hash containing an error message
  def parse_response_body(http_response)
    puts "ApiClient - Parse response"

    return { 'error' => { 'message' => 'No response from API' } } if http_response.nil?

    case http_response.content_type
    when 'application/json'
      # Ruby hash from JSON
      JSON.parse(http_response.body.force_encoding('UTF-8'))
    when 'text/xml'
      # Ruby hash from XML
      Hash.from_xml(http_response.body)
    when 'text/html'
      # Nokogiri XML document from HTML -> Ruby hash from XML
      doc = Nokogiri::HTML(http_response.body)
      Hash.from_xml(doc)
    else
      return { 'error' => { 'message' => "Could not parse response from API (#{http_response.content_type})" } }
    end
  end
end