class SolrMultiQuery < ApiCall
  # for fetching related item data etc.

  require 'open-uri'
  require 'net/http'

  attr_reader :object_uris

  BASE_API_URI = "https://api.parliament.uk/new-solr/"

  def initialize(params)
    @object_uris = params[:object_uris]
  end

  def all_ses_ids
    # this is currently only used for the related items method
    # TODO: refactor to ouput standard data structure
    # this will mean related items method can pass this data on to the SesLookup module in the same format
    # that everything else now uses

    object_data.flat_map { |o| { value: o["all_ses"], field_name: "all_ses" } }.uniq
  end

  def ruby_uri
    # this constructs q=uri: "www.google.com" OR uri: "www.apple.com" OR ...

    uri = build_uri("#{BASE_API_URI}select?q=#{search_string}&rows=50")

    # TODO: this currently returns the first 50 results; this should be set to a sensible number?
  end

  def search_string
    query = object_uris.join("%22 OR uri:%22")
    "(uri:%22#{query}%22)"
  end
end