class SolrSearch < ApiCall

  attr_reader :query, :page, :filter

  def initialize(search_parameters)
    super
    @query = search_parameters[:query]
    @page = search_parameters[:page]
    @filter = search_parameters[:filter]
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

  def query_string
    # multiple fields can be stacked using fq
    # return "fq=questionText_t:%221%22&fq=type_ses:%2292277%22"
    # return "fq=pqStatus_t:%22Answered%22&fq=type_ses:%2292277%22"

    # processing the query separately as it can comprise of multiple components and follows its own pattern
    return unless query || filter

    return "q=%22#{query}%22" if filter.blank?

    return "q=#{filter[:field_name]}:%22#{filter[:value]}%22" if query.blank?

    "q=%22#{query}%22&#{filter[:field_name]}:%22#{filter[:value]}%22"
  end

  def query_chain
    # we can throw everything we want to query into an array depending on whether or not it exists, eg.
    array = []

    unless rows == 10
      array << "rows=#{rows}"
    end

    unless page.blank?
      array << "start=#{start}"
    end

    qs = query_string
    unless qs.blank?
      array << qs
    end

    # return nil if there's nothing in the array
    return if array.empty?

    # if we have anything to search on, join into a string using &
    # this should work in any order
    # e.g. "rows=15&start=40&q="test search query""
    array.join('&')
  end

  def ruby_uri
    build_uri("#{BASE_API_URL}select?#{query_chain}")
  end
end