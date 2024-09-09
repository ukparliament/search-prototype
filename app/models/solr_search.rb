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
      'publisher_ses',
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
      # TODO: refactor once rough logic for different fields is in place

      if field_name == "year"
        # value will be "YYYY"
        selected_year = values.first
        "date_dt:([#{selected_year}-01-01T00:00:00Z TO #{selected_year}-12-31T23:59:59Z])"
      elsif field_name == "month"
        ranges = []
        values.each do |value|
          # value will be "YYYY-MM"
          year = value.split("-").first.to_i
          month = value.split("-").last.to_i
          first_day = Date.new(year, month, 1)
          last_day = Date.new(year, month, -1)
          ranges << "[#{first_day}T00:00:00Z TO #{last_day}T23:59:59Z]"
        end
        "{!tag=month}date_dt:(#{ranges.join(" OR ")})"
      else
        "{!tag=#{field_name}}#{field_name}:(#{values.join(" ")})"
      end
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
        "missing" => true,
        "mincount" => facet_mincount(field_name),
        "domain" => { excludeTags: field_name }
      }
    end

    if filter&.dig(:year).present?
      year = filter.dig(:year).first
      ret['month'] = {
        "type": "range",
        "field": "date_dt",
        "start": "#{year}-01-01T00:00:00Z",
        "end": "#{year}-12-31T23:59:59Z",
        "gap": "+1MONTH",
        "mincount": 0,
        "domain": { excludeTags: 'month' }
      }
    else
      ret['year'] = {
        "type": "range",
        "field": "date_dt",
        "start": "1500-01-01T00:00:00Z",
        "end": "#{Date.today.strftime("%Y-%m-%d")}T23:59:59Z",
        "gap": "+1YEAR",
        "mincount": 1,
        "limit": 100
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
    type_facet_names = ["type_sesrollup"]

    return 80 unless type_facet_names.include?(field_name)

    -1
  end

  def facet_mincount(field_name)
    arr = []
    return 1 unless arr.include?(field_name)

    0 # replacement mincount
  end

  private

  def search_params
    {
      q: search_query,
      'q.op': 'AND',
      fq: search_filter,
      start: start,
      rows: rows,
      sort: sort,
      'json.facet': facet_hash
    }
  end
end