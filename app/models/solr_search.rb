class SolrSearch < ApiCall

  attr_reader :query, :page, :filter, :results_per_page, :sort_by, :search_parameters

  def initialize(search_parameters)
    super
    @search_parameters = search_parameters
    @query = search_parameters[:query]
    @page = search_parameters[:page]
    @results_per_page = search_parameters[:results_per_page]&.to_i
    @filter = search_parameters[:filter]
    @sort_by = search_parameters[:sort_by]
  end

  def self.facet_fields
    ['type_ses', 'type_sesrollup', 'subtype_ses', 'subtype_sesrollup', 'legislativeStage_ses', 'session_t', 'member_ses', 'tablingMember_ses', 'answeringMember_ses', 'legislature_ses']
  end

  def data
    ret = {}
    ret[:search_parameters] = search_parameters unless search_parameters.blank?
    ret[:data] = all_data
    ret
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

  def search_query
    return if query.blank?

    query
  end

  def rows
    # number of results per page; default is 10 in SOLR
    return 20 if results_per_page.blank? || results_per_page.zero?

    results_per_page
  end

  def search_filter
    # "fq": ["field_name:value1", "field_name:value2", ...],

    # For 'OR'
    filter.to_h.flat_map { |field_name, values| values.map { |value| "#{field_name}:#{value}" }.join(" OR ") }

    # Default is 'AND'
    # filter.to_h.flat_map { |field_name, values| values.map { |value| "#{field_name}:#{value}" } }
  end

  def sort
    return 'date_dt desc' if sort_by == "date_desc"
    return 'date_dt asc' if sort_by == "date_asc"

    'date_dt desc'
  end

  private

  def search_params
    {
      q: search_query,
      fq: search_filter,
      start: start,
      rows: rows,
      sort: sort,
      facet: true,
      'facet.limit': -1,
      'facet.field': SolrSearch.facet_fields,
      'facet.missing': false
    }
  end
end