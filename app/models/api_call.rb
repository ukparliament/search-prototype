class ApiCall
  require 'open-uri'
  require 'net/http'

  # attr_reader :object_uri

  BASE_API_URI = "https://api.parliament.uk/search-mock/"
  #BASE_API_URI = "http://localhost:3000/search-mock/"

  def initialize(object_uri)
    @object_uri = object_uri
  end

  def object
    # We construct the URL string to grab the XML from.
    url = full_url(@object_uri)

    # We parse the URL string into a Ruby URI.
    uri = ruby_uri(url)

    # We get the body of the response from deferencing the URI.
    response_body = get_response(uri)

    # We evaluate the body and construct a Ruby hash.
    evaluated = eval(response_body)

    # We return the object.
    evaluated['response']['docs'].first
  end

  private

  def full_url(uri)
    "#{BASE_API_URI}objects.rb?object=#{uri[:object_uri]}"
  end

  def ruby_uri(url)
    URI.parse(url)
  end

  def get_response(uri)
    Net::HTTP.get(uri)
  end
end