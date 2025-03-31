class ExpandQuery

  attr_reader :search_query

  def initialize(search_query)
    @search_query = search_query
  end

  ##
  # Calls extract_terms to generate an array of processable terms.
  #
  # Iterates through the array and processes based on first regex match, returning terms into an array:
  # - Solr operators are returned without alteration
  # - Phrases with no alias are returned without alteration
  # - Aliased phrases, quoted and unquoted strings are passed to the apply_aliases method
  def processed_query
    returned_terms = []

    extract_terms.each do |term|
      if term.match(/\b(?:AND|OR|NOT)\b/i)
        # Solr query operators
        returned_terms << term
      elsif term.match(/(\w+:"(?:[^"]+)")/)
        # field:"phrase in double quotes"
        field_name = term.split(":").first
        search_term = term.split(":").last
        returned_terms << process_term(field_name, search_term)
      elsif term.match(/(\w+:'(?:[^']+)')/)
        # field:'single quoted phrase'
        field_name = term.split(":").first
        search_term = term.split(":").last
        returned_terms << process_term(field_name, search_term)
      elsif term.match(/(\w+:\S+)/)
        # field:string
        field_name = term.split(":").first
        search_term = term.split(":").last
        returned_terms << process_term(field_name, search_term)
      elsif term.match(/"([^"]+)"/)
        # "phrase in double quotes"
        returned_terms << "\"#{term}\""
      elsif term.match(/'([^']+)'/)
        # 'phrase in single quotes'
        returned_terms << "\'#{term}\'"
      elsif term.match(/(\S+)/)
        # string
        search_term = term
        field_name = "none"
        returned_terms << process_term(field_name, search_term)
      else
        raise 'not matched'
      end

    end

    combine_terms(returned_terms)
  end

  def combine_terms(returned_terms)
    # basis of string is first search term
    output_string = "(#{returned_terms.first})"

    # track current end of string as it determines what we do with the next term
    previous_term_is_operator = false

    returned_terms.drop(1).each do |term|
      if %w[AND OR NOT].include?(term.upcase)
        # term is actually an operator, so just add it to the string without doing anything else to it
        # this outcome can stack, e.g. 'term AND NOT term'
        output_string += " #{term}"
        previous_term_is_operator = true
      else
        # term is a genuine term, not an operator
        if previous_term_is_operator
          # previous term was an operator already, so just append the term
          # add parentheses around the term
          output_string += " (#{term})"
          previous_term_is_operator = false
        else
          # previous term was also a genuine term, not an operator, so append with AND
          # add parentheses around the term
          output_string += " AND (#{term})"
          previous_term_is_operator = false
        end
      end
    end

    output_string
  end

  ##
  # Performs term recognition via regex, chunking entered string into component parts:
  #
  # - Returns nil if search_query is not present
  # - Recognises field_name:term or field_name:'term' or field_name:"term" or field_name:"a phrase" or
  # field_name:'a phrase' as a single term
  # - Phrases in isolation are also considered a single term, e.g. "any phrase wrapped in quotes" (both types)
  # - Unquoted words are treated as multiple terms, split on spaces
  # - Returns an array of just the matched terms; flat_map(&:compact) converts the output of .scan into this form
  def extract_terms
    # test input: subject:housing subject:"old houses" subject:"houses" houses "old houses" "houses"
    # which presents as "subject:housing subject:\"old houses\" subject:\"houses\" houses \"old houses\" \"houses\""
    # and is converted into: ["subject:housing", "subject:\"old houses\"", "subject:\"houses\"", "houses", "old houses", "houses"]
    return unless search_query

    search_query.scan(/(\w+:"(?:[^"]+)")|(\w+:'(?:[^']+)')|(\w+:\S+)|"([^"]+)"|'([^']+)'|(\S+)/).flat_map(&:compact)
  end

  ##
  # Accepts an optional field name string and a search term. Search term may be in the form of an unquoted string,
  # or a quoted string or phrase.
  #
  # The field name is used to determine how the term should be processed initially.
  #
  # Initial processing collates text_fields, ses_fields (fields to search the preferred term SES ID,
  # retrieved from SES), ses_id_fields (fields to search with a user-provided SES ID), boolean_fields and date_fields
  # into arrays. A response from the SES API (via the SesQuery class) is also assigned to ses_data.
  #
  # The fields are then expanded using the relevant methods for the field type, with the final collection of
  # terms combined using the 'OR' operator.
  def process_term(field_name = "none", search_term)
    expanded_terms, text_fields, ses_fields, ses_id_fields, boolean_fields, date_fields,
      non_aliased_fields = [], [], [], [], [], [], []

    if field_name == "title"
      text_fields << 'title_t'
      ses_data = SesQuery.new({ value: search_term }).data
    elsif field_name == "subject"
      text_fields << 'subject_t'
      ses_fields << 'subject_ses'
      # topic_ses has been removed, so behaviour here differs from old search by design
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
    elsif field_name.match(/\w+_ses/)
      ses_id_fields << field_name
    elsif field_name == "none"
      non_aliased_fields << field_name
      # catches searches for strings or phrases with no specific field
      ses_fields << "all_ses"
      ses_data = SesQuery.new({ value: search_term }).data
    else
      text_fields << field_name
      ses_data = SesQuery.new({ value: search_term }).data
    end

    expanded_terms << handle_non_aliased_terms(non_aliased_fields, ses_data, search_term)
    expanded_terms << populate_text_fields(text_fields, ses_data, search_term)
    expanded_terms << populate_ses_id_fields(ses_id_fields, search_term)
    expanded_terms << populate_boolean_fields(boolean_fields, search_term)
    expanded_terms << populate_date_fields(date_fields, search_term)
    expanded_terms << populate_ses_fields(ses_fields, ses_data)

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
        expanded_terms << (ses_data[:preferred_term].present? ? "#{tf}:\"#{ses_data[:preferred_term]}\"" : "#{tf}:#{search_term}")
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
        expanded_terms << "#{sif}:\"#{search_term}\""
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
      expanded_terms << (ses_data[:preferred_term].present? ? "\"#{ses_data[:preferred_term]}\"" : "#{search_term}")
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
    unless ses_fields.blank?
      ses_fields.flatten.each do |sf|
        expanded_terms << "#{sf}:#{ses_data[:preferred_term_id]}" if ses_data[:preferred_term_id]
      end
    end

    expanded_terms
  end
end
