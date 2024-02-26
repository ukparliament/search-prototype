class SolrMultiQuery < ApiCall
  # for fetching related item data etc.

  require 'open-uri'
  require 'net/http'

  attr_reader :object_uris

  def initialize(params)
    @object_uris = params[:object_uris]
  end

  def object_data
    super
  end

  def object_filter
    query = object_uris.join(" || uri:")
    "uri:#{query}"
  end

  private

  def search_params
    {
      q: object_filter,
      rows: 500
    }
  end
end