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
    response = evaluated_response
    return response['error'] if response.has_key?('error')

    response
  end

  private

  def api_response(cached = false)
    raise 'Please stub this method to avoid HTTP requests in test environment' if Rails.env.test?

    start_time = Time.now
    response = cached ? api_post_request(search_params) : api_cached_post_request(search_params)

    puts "Received Solr response in #{Time.now - start_time} seconds" if Rails.env.development?
    response
  end

  def evaluated_response
    JSON.parse(api_response(true))
  end

  def build_uri(url)
    # TODO: replace with URI::HTTPS.build(host,path,query (encoded))
    URI.parse(url)
  end

  def api_post_request(params)
    api_endpoint = Rails.application.credentials.dig(Rails.env.to_sym, :solr_api, :endpoint)

    _uri = URI(api_endpoint).dup
    puts "POST request from #{self.class.name}: #{_uri} with data: #{params}" if Rails.env.development?

    http = Net::HTTP.new(_uri.host, _uri.port)
    http.use_ssl = _uri.scheme == 'https'

    # set up the request object
    request = Net::HTTP::Post.new(_uri)
    request.set_form_data(params)
    request_headers_gzip.each { |k, v| request[k] = v }

    # make the request
    response = http.request(request)

    # return the response body
    response.body
  end

  def api_cached_post_request(params)
    # TODO: refactor so that we don't have duplicate methods with/without caching
    api_endpoint = Rails.application.credentials.dig(Rails.env.to_sym, :solr_api, :endpoint)

    _uri = URI(api_endpoint).dup
    puts "POST request from #{self.class.name}: #{_uri} with data: #{params}" if Rails.env.development?

    http = Net::HTTP.new(_uri.host, _uri.port)
    http.use_ssl = _uri.scheme == 'https'

    # set up the request object
    request = Net::HTTP::Post.new(_uri)
    request.set_form_data(params)
    request_headers_gzip.each { |k, v| request[k] = v }

    Rails.cache.fetch(_uri, expires_in: 2.hours) do
      # make the request
      response = http.request(request)

      # return the response body
      response.body
    end
  end

  def api_get_request(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'

    # set up the request object
    request = Net::HTTP::Get.new(uri)
    request_headers_gzip.each { |k, v| request[k] = v }

    # make the request
    response = http.request(request)

    # return the response body
    response.body
  end

  def api_cached_get_request(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'

    # set up the request object
    request = Net::HTTP::Get.new(uri)
    request_headers_gzip.each { |k, v| request[k] = v }

    Rails.cache.fetch(uri, expires_in: 2.hours) do
      # make the request
      response = http.request(request)

      # return the response body
      response.body
    end
  end

  def api_subscription_key
    Rails.application.credentials.dig(Rails.env.to_sym, :solr_api, :subscription_key)
  end

  def request_headers
    { 'Ocp-Apim-Subscription-Key' => api_subscription_key }
  end

  def request_headers_gzip
    { 'Ocp-Apim-Subscription-Key' => api_subscription_key, 'Accept-Encoding' => 'gzip-deflate' }
  end

  def decompress_response(gzip_body)
    Zlib::GzipReader.new(StringIO.new(gzip_body)).read
  end
end