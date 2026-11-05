# frozen_string_literal: true

class ApiClient::Get < ApiClient

  def initialize(uri:, headers:, cache_response: false)
    super
  end

  ##
  # Assemble and make an HTTP GET request, returning a Net::HTTPResponse object.
  def request
    raise 'Please stub this method to avoid HTTP requests in test environment' if Rails.env.test?

    puts "GET request to #{uri} with headers: #{headers}" if Rails.env.development?

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'

    # set up the request object
    request = Net::HTTP::Get.new(uri)
    headers.each { |k, v| request[k] = v }

    # make the request with or without caching
    if cache_response
      Rails.cache.fetch(uri, expires_in: 2.hours) do
        http.request(request)
      end
    else
      http.request(request)
    end
  end
end
