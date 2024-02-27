class SolrSearch < ApiCall

  attr_reader :query, :page, :filter

  def initialize(search_parameters)
    super
    @query = search_parameters[:query]
    @page = search_parameters[:page]
    @filter = search_parameters[:filter]
  end

  def start
    # offset number of rows
    return 0 if page.blank?

    page.to_i * rows
  end

  def search_filter
    "#{filter[:field_name]}:#{filter[:value]}"
  end

  def rows
    # number of results per page; default is 10 in SOLR
    20
  end

  private

  def search_params
    {
      q: search_filter,
      rows: rows,
      start: start
    }
  end
end