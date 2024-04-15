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
    # "fq": ["field_name:value1", "field_name:value2", ...],
    filter.to_h.flat_map { |field_name, values| values.map { |value| "#{field_name}:#{value}" }.join(" OR ") }
  end

  def search_query
    return if query.blank?

    query
  end

  def rows
    # number of results per page; default is 10 in SOLR
    20
  end

  def self.facet_fields
    ['type_ses', 'subtype_ses', 'legislativeStage_ses', 'session_t', 'member_ses', 'tablingMember_ses', 'answeringMember_ses', 'legislature_ses']
  end

  private

  def search_params
    {
      q: search_query,
      fq: search_filter,
      rows: rows,
      start: start,
      facet: true,
      # 'facet.limit': 10,
      'facet.field': SolrSearch.facet_fields,
      # 'facet.range': ['date_dt'],
      # 'facet.range.start': 'NOW/DAY-30DAYS',
      # 'facet.range.end': 'NOW/DAY+30DAYS',
      # 'facet.range.gap': '+1DAY'
    }
  end
end