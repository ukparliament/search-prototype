# frozen_string_literal: true

class ApiClient::Post < ApiClient

  def initialize(uri:, params: {}, headers:, cache_response: false)
    super
  end

  ##
  # Assemble and make an HTTP POST request, returning a Net::HTTPResponse object.
  def request
    raise 'Please stub this method to avoid HTTP requests in test environment' if Rails.env.test?

    puts "POST request to #{uri} with data: #{params} and headers: #{headers}" if Rails.env.development?

    # set up HTTP instance
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'

    # set up the request object
    request = Net::HTTP::Post.new(uri)
    request.set_form_data(params)
    headers.each { |k, v| request[k] = v }

    # make the request
    http.request(request)
  end

end
