class SolrSearch < ApiCall

  attr_reader :query, :page, :type

  def initialize(params)
    super
    @query = params[:query]
    @page = params[:page]
    @type = params[:type_ses]
  end

  def object_data
    return evaluated_response if evaluated_response['statusCode'] == 500

    evaluated_response['response']['docs']
  end

  def result_uris
    object_data.map { |doc| doc["uri"] }
  end

  def start
    # offset number of rows
    return 0 if page.blank?

    page.to_i * rows
  end

  def rows
    # number of results per page; default is 10 in SOLR
    20
  end

  def ruby_uri
    build_uri("#{BASE_API_URI}select?q=%22#{query}%22&rows=#{rows}&start=#{start}")
  end

  # TODO: we can search for a specific term / filter by adding to the query string
  # select?q=type_ses:#{type}
end