class ExpandQuery

  attr_reader :search_query, :ses_search_class

  def initialize(search_query, ses_search_class)
    @search_query = search_query
    @ses_search_class = ses_search_class
  end

  ##
  # Calls extract_terms to generate an array of processable terms.
  #
  # Iterates through the array and processes based on first regex match, returning terms into an array.
  # Depending on the field, it may:
  # - Return a term largely unaltered (e.g. Solr operators)
  # - Call expand_fields to add additional fields that should be searched
  # - Call expand_terms to add additional terms that should be searched for
  # - Fetch a SES API response (via SesQuery class) for the search term, where required by expand_terms
  def process_query
    returned_terms = []

    # TODO: refactor
    extract_terms.each do |term|
      if term.match(/\b(?:AND|OR|NOT)\b/i)
        # Solr query operators
        returned_terms << term
      elsif term.match(/(\w+:"(?:[^"]+)")/)
        # field:"phrase in double quotes"
        field_name = term.split(":").first
        search_term = term.split(":").last
        ses_data = ses_search_class.new({ value: search_term }).data
        expanded_fields = expand_fields(field_name)
        returned_terms << expand_terms(expanded_fields, ses_data, search_term)
      elsif term.match(/(\w+:'(?:[^']+)')/)
        # field:'single quoted phrase'
        field_name = term.split(":").first
        search_term = term.split(":").last
        ses_data = ses_search_class.new({ value: search_term }).data
        expanded_fields = expand_fields(field_name)
        returned_terms << expand_terms(expanded_fields, ses_data, search_term)
      elsif term.match(/(\w+:\S+)/)
        # field:string
        field_name = term.split(":").first
        search_term = term.split(":").last
        expanded_fields = expand_fields(field_name)
        ses_data = ses_search_class.new({ value: search_term }).data
        returned_terms << expand_terms(expanded_fields, ses_data, search_term)
      elsif term.match(/"([^"]+)"/)
        # "phrase in double quotes"
        returned_terms << term
      elsif term.match(/'([^']+)'/)
        # 'phrase in single quotes'
        returned_terms << term
      elsif term.match(/(\S+)/)
        # string
        search_term = term
        field_name = "none"
        expanded_fields = expand_fields(field_name)
        ses_data = ses_search_class.new({ value: search_term }).data
        returned_terms << expand_terms(expanded_fields, ses_data, search_term)
      else
        raise 'not matched'
      end

    end

    returned_terms
  end

  ##
  # Performs term recognition via regex, chunking entered string into component parts:
  #
  # - Returns nil if search_query is not present
  # - Converts search_query to a string
  # - Recognises field_name:term or field_name:'term' or field_name:"term" or field_name:"a phrase" or
  # field_name:'a phrase' as a single term
  # - Phrases in isolation are also considered a single term, e.g. "any phrase wrapped in quotes" (both types)
  # - Unquoted words are treated as multiple terms, split on spaces
  # - Returns an array of just the matched terms; flat_map(&:compact) converts the output of .scan into this form
  def extract_terms
    # test input: subject:housing subject:"old houses" subject:"houses" houses "old houses" "houses"
    # which presents as "subject:housing subject:\"old houses\" subject:\"houses\" houses \"old houses\" \"houses\""
    # and is converted into: ["subject:housing", "subject:\"old houses\"", "subject:\"houses\"", "houses", "old houses", "houses"]
    return if search_query.blank?

    search_query.to_s.scan(/(\w+:"(?:[^"]+)")|(\w+:'(?:[^']+)')|(\w+:\S+)|"([^"]+)"|'([^']+)'|(\S+)/).flat_map(&:compact)
  end

  ##
  # Accepts an optional field name.
  #
  # Collates text_fields, ses_fields (fields to search the preferred term SES ID,
  # retrieved from SES), ses_id_fields (fields to search with a user-provided SES ID), boolean_fields and date_fields
  # into arrays, returned as a hash.
  def expand_fields(field_name = "none")
    text_fields, ses_fields, ses_id_fields, boolean_fields, date_fields, non_aliased_fields = [], [], [], [], [], []

    if field_name == "title"
      text_fields = ['title_t']
    elsif field_name == "subject"
      text_fields = ['subject_t']
      ses_fields = ['subject_ses']
      # topic_ses has been removed, so behaviour here differs from old search by design
    elsif field_name == "author"
      # extra: correspondingMinister_t, epCommittee_t, department_t etc are all only the submitted term (dwp) in example, whereas we're searching all equivalents too
      # this seems to be unintentional behaviour in the original search code; for the time being we're leaving this alone
      text_fields = %w[creator_t contributor_t corporateAuthor_t epCommittee_t department_t correspondingMinister_t]
      ses_fields = %w[creator_ses contributor_ses corporateAuthor_ses mep_ses section_ses tablingMember_ses askingMember_ses answeringMember_ses department_ses member_ses leadMember_ses correspondingMinister_ses]
    elsif field_name == "explanatorymemorandum"
      boolean_fields = %w[containsEM_b]
    elsif field_name == "datecertified"
      date_fields = %w[dateCertified_dt certifiedDate_dt]
    elsif field_name == "date"
      date_fields = %w[date_dt]
    elsif field_name.match(/\w+_dt/)
      # if searching a _dt field specifically, treat it as a date field so that 'lastweek' etc. all work
      date_fields = [field_name]
    elsif field_name.match(/\w+_ses/)
      ses_id_fields = [field_name]
    elsif field_name == "none"
      non_aliased_fields = [field_name]
      # catches searches for strings or phrases with no specific field
      ses_fields = ["all_ses"]
    else
      text_fields = [field_name]
    end

    {
      'text_fields' => text_fields,
      'ses_fields' => ses_fields,
      'ses_id_fields' => ses_id_fields,
      'boolean_fields' => boolean_fields,
      'date_fields' => date_fields,
      'non_aliased_fields' => non_aliased_fields
    }
  end

  def expand_terms(expanded_fields, ses_data, search_term)
    expanded_terms = []

    unless expanded_fields["non_aliased_fields"].empty?
      expanded_terms << handle_non_aliased_terms(expanded_fields["non_aliased_fields"], ses_data, search_term)
    end

    unless expanded_fields["text_fields"].empty?
      expanded_terms << populate_text_fields(expanded_fields["text_fields"], ses_data, search_term)
    end

    unless expanded_fields["ses_id_fields"].empty?
      expanded_terms << populate_ses_id_fields(expanded_fields["ses_id_fields"], search_term)
    end

    unless expanded_fields["boolean_fields"].empty?
      expanded_terms << populate_boolean_fields(expanded_fields["boolean_fields"], search_term)
    end

    unless expanded_fields["date_fields"].empty?
      expanded_terms << populate_date_fields(expanded_fields["date_fields"], search_term)
    end

    unless expanded_fields["ses_fields"].empty?
      expanded_terms << populate_ses_fields(expanded_fields["ses_fields"], ses_data)
    end

    # combine all new search terms with OR
    expanded_terms.flatten.join(' OR ')
  end

  ##
  # Retrieve the preferred term and synonyms from SES data and apply them across all text fields
  # Where preferred term is not present, apply the search term instead
  def populate_text_fields(text_fields, ses_data, search_term)
    expanded_terms = []

    unless text_fields.blank?
      text_fields.flatten.each do |tf|
        expanded_terms << (ses_data[:preferred_term].present? ? "#{tf}:\"#{ses_data[:preferred_term]}\"" : "#{tf}:\"#{search_term}\"")
        ses_data[:equivalent_terms].flatten.each do |et|
          expanded_terms << "#{tf}:\"#{et}\""
        end
      end
    end

    expanded_terms
  end

  ##
  # Search all SES ID fields with the SES ID provided as a search term.
  def populate_ses_id_fields(ses_id_fields, search_term)
    expanded_terms = []

    unless ses_id_fields.blank?
      ses_id_fields.flatten.each do |sif|
        expanded_terms << "#{sif}:#{search_term}"
      end
    end

    expanded_terms
  end

  ##
  # Search all boolean fields with '1' or '0' depending on entered term
  def populate_boolean_fields(boolean_fields, search_term)
    expanded_terms = []

    unless boolean_fields.blank?
      boolean_fields.flatten.each do |bf|
        if %w[true yes y 1].include?(search_term)
          expanded_terms << "#{bf}:1"
        elsif %w[false no n 0].include?(search_term)
          expanded_terms << "#{bf}:0"
        end
      end
    end

    expanded_terms
  end

  ##
  # Search across date fields based on the supplied alias
  def populate_date_fields(date_fields, search_term)
    expanded_terms = []

    unless date_fields.blank?
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

    expanded_terms
  end

  ##
  # Where no alias was given, the search term is replaced with the preferred term if present, and expanded
  # further with equivalent terms, if present.
  def handle_non_aliased_terms(non_aliased_fields, ses_data, search_term)
    expanded_terms = []

    unless non_aliased_fields.blank?
      expanded_terms << (ses_data[:preferred_term].present? ? "\"#{ses_data[:preferred_term]}\"" : "\"#{search_term}\"")
      ses_data[:equivalent_terms].flatten.each do |et|
        expanded_terms << "\"#{et}\""
      end
    end

    expanded_terms
  end

  ##
  # Search all SES fields with the preferred term ID, if present.
  def populate_ses_fields(ses_fields, ses_data)
    expanded_terms = []

    # add every SES field we've determined should be searched for the preferred term SES ID
    unless ses_fields.blank? || ses_data.blank? || ses_data[:preferred_term_id].blank?
      ses_fields.flatten.each do |sf|
        expanded_terms << "#{sf}:#{ses_data[:preferred_term_id]}" if ses_data[:preferred_term_id]
      end
    end

    expanded_terms
  end
end
