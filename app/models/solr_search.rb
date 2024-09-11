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
      'legislature_ses',
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
      elsif field_name == "session"
        ranges = []
        values.each do |value|
          ranges << session_range_lookup(value)
        end
        # "{!tag=session_t}date_dt:(#{ranges.join(" OR ")})"
        "{!tag=session_t}(date_dt:(#{ranges.join(" OR ")}) OR session_t:(#{values.join(" OR ")}))"
      else
        "{!tag=#{field_name}}#{field_name}:(#{values.join(" ")})"
      end
    end
  end

  def session_range_lookup(value)
    # TODO: this will likely become a Session model, with persistance and admin features to set the names
    # as well as 'from' and 'to' dates.

    case value
    when '2024-25'
      '[2024-05-25T00:00:00Z TO *]'
    when '2023-24'
      '[2023-10-27T00:00:00Z TO 2024-05-24T23:59:00Z]'
    when '2022-23'
      '[2022-04-29T00:00:00Z TO 2023-10-26T23:59:59Z]'
    when '2021-22'
      '[2021-05-11T00:00:00Z TO 2022-04-28T23:59:59Z]'
    when '2019-21'
      '[2019-12-17T00:00:00Z TO 2021-05-10T23:59:59Z]'
    when '2019-19'
      '[2019-10-14T01:00:00Z TO 2019-11-06T00:01:00Z]'
    when '2017-19'
      '[2017-05-03T00:00:00Z TO 2019-10-13T23:59:59Z]'
    when '2016-17'
      '[2016-05-13T00:00:00Z TO 2017-05-02T23:59:59Z]'
    when '2015-16'
      '[2015-04-01T00:00:00Z TO 2016-05-12T23:59:59Z]'
    when '2014-15'
      '[2014-05-14T23:00:00Z TO 2015-03-30T23:59:59Z]'
    when '2013-14'
      '[2013-04-25T23:00:00Z TO 2014-06-03T22:59:59Z]'
    when '2012-13'
      '[2012-05-08T23:00:00Z TO 2013-04-25T22:59:59Z]'
    when '2010-12'
      '[2010-05-17T23:00:00Z TO 2012-05-08T22:59:59Z]'
    when '2009-10'
      '[2009-11-18T00:00:00Z TO 2010-05-17T22:59:59Z]'
    when '2008-09'
      '[2008-12-03T00:00:00Z TO 2009-11-17T23:59:59Z]'
    when '2007-08'
      '[2007-11-06T00:00:00Z TO 2008-12-02T23:59:59Z]'
    when '2006-07'
      '[2006-11-15T00:00:00Z TO 2007-11-05T23:59:59Z]'
    when '2005-06'
      '[2005-05-10T23:00:00Z TO 2006-11-14T23:59:59Z]'
    when '2004-05'
      '[2004-11-23T00:00:00Z TO 2005-05-10T22:59:59Z]'
    when '2003-04'
      '[2003-11-26T00:00:00Z TO 2004-11-22T23:59:59Z]'
    when '2002-03'
      '[2002-11-10T00:00:00Z TO 2003-11-25T23:59:59Z]'
    when '2001-02'
      '[2001-06-12T23:00:00Z TO 2002-11-09T23:59:59Z]'
    when '2000-01'
      '[2000-12-06T00:00:00Z TO 2001-06-12T22:59:59Z]'
    when '1999-00'
      '[1999-11-17T00:00:00Z TO 2000-12-05T23:59:59Z]'
    when '1998-99'
      '[1998-11-24T00:00:00Z TO 1999-11-16T23:59:59Z]'
    when '1997-98'
      '[1997-05-06T23:00:00Z TO 1998-11-23T23:59:59Z]'
    when '1996-97'
      '[1996-10-22T23:00:00Z TO 1997-05-06T22:59:59Z]'
    when '1995-96'
      '[1995-11-15T00:00:00Z TO 1996-10-22T22:59:59Z]'
    when '1994-95'
      '[1994-11-16T00:00:00Z TO 1995-11-14T23:59:59Z]'
    when '1993-94'
      '[1993-11-18T00:00:00Z TO 1994-11-15T23:59:59Z]'
    when '1992-93'
      '[1992-04-26T23:00:00Z TO 1993-11-17T23:59:59Z]'
    when '1991-92'
      '[1991-10-31T00:00:00Z TO 1992-04-26T22:59:59Z]'
    when '1990-91'
      '[1990-11-07T00:00:00Z TO 1991-10-30T23:59:59Z]'
    when '1989-90'
      '[1989-11-21T00:00:00Z TO 1990-11-06T23:59:59Z]'
    when '1988-89'
      '[1988-11-22T00:00:00Z TO 1989-11-20T23:59:59Z]'
    when '1987-88'
      '[1987-06-16T23:00:00Z TO 1988-11-21T23:59:59Z]'
    when '1986-87'
      '[1986-11-12T00:00:00Z TO 1987-06-16T22:59:59Z]'
    when '1985-86'
      '[1985-11-05T00:00:00Z TO 1986-11-11T23:59:59Z]'
    when '1984-85'
      '[1984-11-06T00:00:00Z TO 1985-11-04T23:59:59Z]'
    when '1983-84'
      '[1983-06-14T23:00:00Z TO 1984-11-05T23:59:59Z]'
    when '1982-83'
      '[1982-11-03T00:00:00Z TO 1983-06-14T22:59:59Z]'
    when '1981-82'
      '[1981-11-04T00:00:00Z TO 1982-11-02T23:59:59Z]'
    when '1980-81'
      '[1980-11-20T00:00:00Z TO 1981-11-03T23:59:59Z]'
    when '1979-80'
      '[1979-05-08T23:00:00Z TO 1980-11-19T23:59:59Z]'
    else
      ''
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

    SolrSearch.sessions.each do |session|
      ret["session_#{session}"] = {
        "type": "query",
        "q": "(session_t:#{session} OR date_dt:#{session_range_lookup(session)})"
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
    # limit to 80 except for
    facet_names = ["type_sesrollup"]

    return 80 unless facet_names.include?(field_name)

    -1
  end

  def facet_mincount(field_name)
    arr = []
    return 1 unless arr.include?(field_name)

    0 # replacement mincount
  end

  def self.sessions
    [
      '2024-25',
      '2023-24',
      '2022-23',
      '2021-22',
      '2019-21',
      '2019-19',
      '2017-19',
      '2016-17',
      '2015-16',
      '2014-15',
      '2013-14',
      '2012-13',
      '2010-12',
      '2009-10',
      '2008-09',
      '2007-08',
      '2006-07',
      '2005-06',
      '2004-05',
      '2003-04',
      '2002-03',
      '2001-02',
      '2000-01',
      '1999-00',
      '1998-99',
      '1997-98',
      '1996-97',
      '1995-96',
      '1994-95',
      '1993-94',
      '1992-93',
      '1991-92',
      '1990-91',
      '1989-90',
      '1988-89',
      '1987-88',
      '1986-87',
      '1985-86',
      '1984-85',
      '1983-84',
      '1982-83',
      '1981-82',
      '1980-81',
      '1979-80'
    ]
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