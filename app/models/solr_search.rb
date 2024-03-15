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
    # start at 0 (the first record) by default:
    return 0 if user_requested_page.zero? || user_requested_page.blank?

    # if a page number is given, offset by a number of records equal to the number per page * (solr) page number
    current_page * rows
  end

  def user_requested_page
    # this is the 1-indexed (we assume) user requested page (from the url)
    page.to_i&.zero? ? 1 : page.to_i
  end

  def current_page
    # this is the solr zero-indexed page number; subtract 1 from what the user asked for
    user_requested_page - 1
  end

  def search_filter
    return if filter.blank?

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