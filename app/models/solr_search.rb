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
    # ['type_sesrollup', 'subtype_sesrollup', 'legislativeStage_ses', 'session_t', 'member_ses', 'tablingMember_ses', 'answeringMember_ses', 'legislature_ses']

    [
      'type_sesrollup',
      'legislature_ses',
      'session_t',
      'date_dt',
      'department_ses',
      'member_ses',
      'tablingMember_ses',
      'askingMember_ses',
      'leadMember_ses',
      'answeringMember_ses',
      'legislativeStage_ses',
      'legislationTitle_ses',
      'subject_ses',
      'topic_ses'
    ]
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
    return 10 if results_per_page.blank? || results_per_page.zero?

    results_per_page
  end

  def search_filter
    # search filter submitted as fq
    # "fq": ["field_name:value1", "field_name:value2", ...],

    # input data ('filter') is a params object, e.g.:
    # {"type_sesrollup"=>["445871", "90996"]}

    # For 'OR'
    # filter.to_h.flat_map { |field_name, values| values.map { |value| "#{field_name}:#{value}" }.join(" OR ") }
    filter.to_h.flat_map { |field_name, values| values.map { |value| "{!tag=#{field_name}}#{field_name}:#{value}" }.join(" OR ") }

    # Default is 'AND'; we have elected to use 'OR' except for date (further requirements needed)
    # filter.to_h.flat_map { |field_name, values| values.map { |value| "#{field_name}:#{value}" } }

    # TODO: reformat and tag filters such that they can be excluded when setting up facets
    # "filter": "{!tag=TAGNAME}field_name:term",

    # search_filters = "{!tag=CTP}type_sesrollup:90996"
  end

  def sort
    return 'date_dt desc' if sort_by == "date_desc"
    return 'date_dt asc' if sort_by == "date_asc"

    'date_dt desc'
  end

  def facet_hash
    # hash with keys as names of facets

    ret = {}
    SolrSearch.facet_fields.each do |field_name|

      ret[field_name] = {
        'type' => 'terms',
        'field' => field_name,
        'limit' => 100,
        'domain' => { excludeTags: field_name }
      }

    end

    # domain: { excludeTags: 'CTP' }
    ret.to_json

  end

  private

  def search_params
    {
      q: search_query, # q (query) is the main criteria for matching results
      'q.op': 'AND',
      fq: search_filter, # fq (filter query) is used to apply filters that cut down the result set without affecting scoring
      start: start,
      rows: rows,
      sort: sort,
      'json.facet': facet_hash
    }
  end
end