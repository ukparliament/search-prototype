class SolrMultiQuery < ApiCall

  require 'open-uri'
  require 'net/http'

  attr_reader :object_uris, :field_list

  def initialize(params)
    @object_uris = params[:object_uris]
    @field_list = params[:field_list]
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
      fl: field_list,
      'q.op': 'OR',
      rows: 500
    }
  end
end