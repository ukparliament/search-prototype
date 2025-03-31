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
    [
      'type_sesrollup',
      'legislature_ses',
      'date_year',
      'date_month',
      'session_t',
      'department_ses',
      'member_ses',
      'primaryMember_ses',
      'answeringMember_ses',
      'legislativeStage_ses',
      'legislationTitle_ses',
      'publisher_ses',
      'subject_ses'
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
    # search filter submitted as fq
    # "fq": ["field_name:value1", "field_name:value2", ...],

    # input data ('filter') is a params object, e.g.:
    # {"type_sesrollup"=>["445871", "90996"]}

    # filters are tagged so that they can be excluded from facet counts
    # "filter": "{!tag=TAGNAME}field_name:term",

    # Alternative syntax for logical union of multiple values for the same field:
    # &fq={!tag=COLOR}color:(Blue Black)

    filter.to_h.flat_map do |field_name, values|
      "{!tag=#{field_name}}#{field_name}:(#{values.join(" ")})"
    end
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
        "type" => facet_type(field_name),
        "field" => field_name,
        "limit" => facet_limit(field_name),
        "mincount" => facet_mincount(field_name),
        "domain" => { excludeTags: field_name }
      }
    end

    ret.to_json
  end

  def facet_type(field_name)
    arr = []
    return "terms" unless arr.include?(field_name)

    " " # replacement type
  end

  def facet_limit(field_name)
    facet_names = ["type_sesrollup"]

    return 100 unless facet_names.include?(field_name)

    -1
  end

  def facet_mincount(field_name)
    arr = []
    return 1 unless arr.include?(field_name)

    0 # replacement mincount
  end

  def field_list
    # Fields required from initial search; as few as possible for speed
    'uri type_ses subtype_ses'
  end

  def query_processor
    ExpandQuery.new(search_query).processed_query
  end

  private

  def search_params
    {
      q: query_processor,
      'q.op': 'AND',
      fq: search_filter,
      fl: field_list,
      start: start,
      rows: rows,
      sort: sort,
      'json.facet': facet_hash
    }
  end
end