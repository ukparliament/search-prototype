class SolrQuery < ApiCall
  require 'open-uri'
  require 'net/http'

  attr_reader :object_uri

  # BASE_API_URI = "https://api.parliament.uk/search-mock/"
  # BASE_API_URI = "http://localhost:3000/search-mock/"
  BASE_API_URI = "https://api.parliament.uk/new-solr/"

  def initialize(params)
    @object_uri = params[:object_uri]
  end

  def object_data
    return evaluated_response if evaluated_response['statusCode'] == 500

    evaluated_response['response']['docs'].first
  end

  def ruby_uri
    # build_uri("#{BASE_API_URI}objects.json?object=#{object_uri}")

    build_uri("#{BASE_API_URI}select?q=uri:%22#{object_uri}%22")
  end
end