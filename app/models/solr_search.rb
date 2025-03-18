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

  def processed_query
    # performs term recognition via regex
    terms = extract_terms(search_query)

    returned_terms = []

    terms.each do |term|
      # terms can then have field_name:string, field_name:"string", field_name:"string string", field_name:number,
      # number, string or "string string" and we need to handle both aliases and query expansion for all of them

      if term.match(/\b(?:AND|OR|NOT)\b/i)
        # Solr query operators
        returned_terms << term
      elsif term.match(/(\w+:"(?:[^"]+)")/)
        # field:"phrase in double quotes"
        field_name = term.split(":").first
        search_term = term.split(":").last
        returned_terms << apply_aliases(field_name, search_term)
      elsif term.match(/(\w+:'(?:[^']+)')/)
        # field:'single quoted phrase'
        field_name = term.split(":").first
        search_term = term.split(":").last
        returned_terms << apply_aliases(field_name, search_term)
      elsif term.match(/(\w+:\S+)/)
        # field:string
        field_name = term.split(":").first
        search_term = term.split(":").last
        returned_terms << apply_aliases(field_name, search_term)
      elsif term.match(/"([^"]+)"/)
        # "phrase in double quotes"
        # TODO: expansion of phrases
        returned_terms << "\"#{term}\""
      elsif term.match(/'([^']+)'/)
        # TODO: expansion of phrases
        # 'phrase in single quotes'
        returned_terms << "\'#{term}\'"
      elsif term.match(/(\S+)/)
        # string
        # returned_terms << "\"#{term}\""
        search_term = term
        field_name = "none"
        returned_terms << apply_aliases(field_name, search_term)
      else
        raise 'not matched'
      end

    end

    # combine all separately entered terms with a space;
    # these will be combined using AND, as configured by SolrSearch params (q.op)
    returned_terms.join(' ')
  end

  def extract_terms(input)
    # test input: subject:housing subject:"old houses" subject:"houses" houses "old houses" "houses"
    # which presents as "subject:housing subject:\"old houses\" subject:\"houses\" houses \"old houses\" \"houses\""
    # and is converted into: ["subject:housing", "subject:\"old houses\"", "subject:\"houses\"", "houses", "old houses", "houses"]

    input.scan(/(\w+:"(?:[^"]+)")|(\w+:'(?:[^']+)')|(\w+:\S+)|"([^"]+)"|'([^']+)'|(\S+)/).flat_map(&:compact)
  end

  def apply_aliases(field_name = "none", search_term)
    expanded_terms = []
    text_fields = []
    ses_fields = []
    boolean_fields = []
    date_fields = []

    # TODO: this logic can be transferred to a database-backed model for admin interface interaction
    if field_name == "title"
      text_fields << 'title_t'
      ses_data = SesQuery.new({ value: search_term }).data
    elsif field_name == "subject"
      text_fields << 'subject_t'
      ses_fields << 'subject_ses'
      ses_data = SesQuery.new({ value: search_term }).data
    elsif field_name == "author"
      # extra: correspondingMinister_t, epCommittee_t, department_t etc are all only the submitted term (dwp) in example, whereas we're searching all equivalents too
      # this seems to be unintentional behaviour in the original search code; for the time being we're leaving this alone
      text_fields << %w[creator_t contributor_t corporateAuthor_t epCommittee_t department_t correspondingMinister_t]
      ses_fields << %w[creator_ses contributor_ses corporateAuthor_ses mep_ses section_ses tablingMember_ses askingMember_ses answeringMember_ses department_ses member_ses leadMember_ses correspondingMinister_ses]
      ses_data = SesQuery.new({ value: search_term }).data
    elsif field_name == "explanatorymemorandum"
      # might need to introduce boolean fields as a concept for this to work correctly?
      boolean_fields << %w[containsEM_b]
    elsif field_name == "datecertified"
      date_fields << %w[dateCertified_dt certifiedDate_dt]
    elsif field_name == "date"
      date_fields << %w[date_dt]
    elsif field_name.match(/\w+_dt/)
      # if searching a _dt field specifically, treat it as a date field so that 'lastweek' etc. all work
      date_fields << field_name
    elsif field_name == "none"
      # catches searches for strings or phrases with no specific field
      ses_data = SesQuery.new({ value: search_term }).data
    else
      text_fields << field_name
      ses_data = SesQuery.new({ value: search_term }).data
    end

    # in every field we've determined should be searched for text, look for the original term & all equivalents
    unless text_fields.blank?
      text_fields.flatten.each do |tf|
        expanded_terms << "#{tf}:#{search_term}"
        expanded_terms << "#{tf}:\"#{ses_data[:primary_term]}\""
        ses_data[:equivalent_terms].flatten.each do |et|
          expanded_terms << "#{tf}:\"#{et}\""
        end
      end
    end

    # add every SES field we've determined should be searched for the 'primary' SES ID
    unless ses_fields.blank?
      ses_fields.flatten.each do |sf|
        expanded_terms << "#{sf}:#{ses_data[:primary_id]}" if ses_data[:primary_id]
      end
    end

    # apply boolean value against all boolean fields
    unless boolean_fields.blank?
      boolean_fields.flatten.each do |bf|
        if %w[true yes y 1].include?(search_term)
          expanded_terms << "#{bf}:1"
        elsif %w[false no n 0].include?(search_term)
          expanded_terms << "#{bf}:0"
        end
      end
    end

    unless date_fields.blank?
      # questions here:
      # - does it matter if some of the date ranges go into the future? I would assume not - results will be the same
      # - isn't it a bit odd if thisweek and lastweek exclude weekends, when other ranges (like thismonth) don't?

      date_lookup = {
        'today': "NOW/DAY",
        'yesterday': "NOW/DAY-1DAY",
        'thisweek': "[NOW/WEEK TO NOW/WEEK+6DAYS]",
        'lastweek': "[NOW/WEEK-1WEEK TO NOW/WEEK-1DAY]",
        'thismonth': "[NOW/MONTH TO NOW/MONTH+1MONTH-1MILLISECOND]",
        'lastmonth': "[NOW/MONTH-1MONTH TO NOW/MONTH-1MILLISECOND]",
        'thisyear': "[NOW/YEAR TO NOW/YEAR+1YEAR-1MILLISECOND]",
        'lastyear': "[NOW/YEAR-1YEAR TO NOW/YEAR-1MILLISECOND]"
      }

      parsed_date = date_lookup[search_term.to_sym].nil? ? search_term : date_lookup[search_term.to_sym]
      date_fields.flatten.each do |df|
        expanded_terms << "#{df}:#{parsed_date}"
      end
    end

    if field_name == "none"
      expanded_terms << "#{search_term}"
      expanded_terms << "\"#{ses_data[:primary_term]}\""
      ses_data[:equivalent_terms].flatten.each do |et|
        expanded_terms << "\"#{et}\""
      end
    end

    # combine all new search terms with OR
    expanded_terms.join(' OR ')
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

  private

  def search_params
    {
      q: processed_query,
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