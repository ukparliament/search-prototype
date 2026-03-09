class ExpandQuery

  EXPAND_UNQUOTED_PHRASES = ENV["expand_unquoted_phrases"] || Rails.application.credentials.dig(:expand_unquoted_phrases)
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
  # - Return a term unaltered (e.g. Solr boolean operators such as AND)
  # - Call expand_fields to add additional fields that should be searched
  # - Call expand_terms to add additional terms that should be searched for
  # - Fetch a SES API response (via SesQuery class) for the search term, where required by expand_terms
  #
  # Stopwords (lowercase and, or etc.) are not removed from phrases; Solr handles these as part of its own tokenisation
  # process
  def process_query
    tokens = []

    extract_terms.each do |term|
      if term.match(/\b(?:AND|OR|NOT)\b/i)
        tokens << [:operator, term]
      elsif term.match(/(\w+:"(?:[^"]+)")/)
        tokens << [:specified_field_with_quoted_phrase, term]
      elsif term.match(/(\w+:'(?:[^']+)')/)
        tokens << [:specified_field_with_quoted_phrase, term]
      elsif term.match(/(\w+:\[(?:[^\]]+)\])/)
        tokens << [:specified_field_no_expansion, term]
      elsif term.match(/(\w+:\S+)/)
        tokens << [:specified_field, term]
      elsif term.match(/"([^"]+)"/)
        tokens << [:quoted_phrase, term]
      elsif term.match(/'([^']+)'/)
        tokens << [:quoted_phrase, term]
      elsif term.match(/\[(?:[^\]]+)\]/)
        tokens << [:no_expansion, term]
      else
        tokens << [:unquoted_word, term]
      end
    end

    grouped_tokens = group_unquoted_words_as_phrases(tokens)
    processed_tokens = []

    grouped_tokens.each do |label, value|
      if label == :operator
        # do nothing, pass directly to Solr
        search_term = value
        processed_tokens << search_term
      elsif label == :specified_field_with_quoted_phrase
        search_term = value.split(":").last
        field_name = value.split(":").first
        ses_data = ses_search_class.new({ value: search_term }).data
        expanded_fields = expand_fields(field_name)
        processed_tokens << expand_terms(expanded_fields, ses_data, search_term)
      elsif label == :specified_field_no_expansion
        # delete unwanted []; expand fields using blank SES data
        search_term = value.split(":").last.delete_prefix("[").delete_suffix("]")
        field_name = value.split(":").first
        expanded_fields = expand_fields(field_name)
        processed_tokens << expand_terms(expanded_fields, {}, search_term)
      elsif label == :specified_field
        search_term = value.split(":").last
        field_name = value.split(":").first
        expanded_fields = expand_fields(field_name)
        ses_data = ses_search_class.new({ value: search_term }).data
        processed_tokens << expand_terms(expanded_fields, ses_data, search_term)
      elsif label == :quoted_phrase
        search_term = value
        expanded_fields = expand_fields("none")
        ses_data = ses_search_class.new({ value: search_term }).data
        processed_tokens << expand_terms(expanded_fields, ses_data, search_term)
      elsif label == :no_expansion
        search_term = value.delete_prefix("[").delete_suffix("]")
        processed_tokens << search_term
      elsif label == :unquoted_phrase
        search_term = value
        expanded_fields = expand_fields("none")
        ses_data = ses_search_class.new({ value: search_term }).data if ExpandQuery::EXPAND_UNQUOTED_PHRASES
        if ses_data.present?
          processed_tokens << expand_terms(expanded_fields, ses_data, search_term)
        else
          # return the token without expansion
          processed_tokens << value
        end
      else
        puts "Unmatched token type #{label} for #{value}" if Rails.env.development?
        next
      end
    end

    processed_tokens
  end

  ##
  # Performs tokenisation via regex, chunking entered string into component parts:
  # - Returns nil if search_query is not present.
  # - Converts search_query to a string.
  # - Recognises specified fields, e.g. field_name:term or field_name:'term' or field_name:"term" or
  #   field_name:"a phrase" or field_name:'a phrase' as a single token.
  # - Phrases in isolation are also considered a single token, e.g. "any phrase wrapped in quotes" (both types)
  # - Unquoted words are treated as multiple tokens, split on spaces (these are combined later on).
  # - Returns an array of just the matched terms; flat_map(&:compact) converts the output of .scan into this form
  def extract_terms
    # test input: subject:housing subject:"old houses" subject:"houses" houses "old houses" "houses"
    # which presents as "subject:housing subject:\"old houses\" subject:\"houses\" houses \"old houses\" \"houses\""
    # and is converted into: ["subject:housing", "subject:\"old houses\"", "subject:\"houses\"", "houses", "old houses", "houses"]
    return if search_query.blank?
    search_query.to_s.scan(/(\w+:"(?:[^"]+)")|(\w+:'(?:[^']+)')|(\w+:\[(?:[^\]]+)\])|(\w+:\S+)|(\[(?:[^\]]+)\])|"([^"]+)"|'([^']+)'|(\S+)/).flat_map(&:compact)
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
  # This is done iteratively as SES may return multiple terms with multiple equivalent terms each
  # Where preferred term is not present, apply the search term instead
  def populate_text_fields(text_fields, ses_data, search_term)
    expanded_terms = []

    unless text_fields.blank?
      text_fields.flatten.each do |tf|
        ses_data.each do |ses_result|
          expanded_terms << (ses_result[:preferred_term].present? ? "#{tf}:\"#{ses_result[:preferred_term]}\"" : "#{tf}:\"#{search_term}\"")
          ses_result[:equivalent_terms].flatten.each do |et|
            expanded_terms << "#{tf}:\"#{et}\""
          end
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
  # This is done iteratively as SES may return multiple terms with multiple equivalent terms each.
  def handle_non_aliased_terms(non_aliased_fields, ses_data, search_term)
    expanded_terms = []
    unless non_aliased_fields.blank?
      ses_data.each do |ses_result|
        expanded_terms << (ses_result[:preferred_term].present? ? "\"#{ses_result[:preferred_term]}\"" : "\"#{search_term}\"")
        ses_result[:equivalent_terms].flatten.each do |et|
          expanded_terms << "\"#{et}\""
        end
      end
    end

    expanded_terms
  end

  ##
  # Search all SES fields with the preferred term ID, if present.
  # SES data may return multiple terms, so this is done iteratively.
  def populate_ses_fields(ses_fields, ses_data)
    expanded_terms = []

    # add every SES field we've determined should be searched for the preferred term SES ID
    unless ses_fields.blank? || ses_data.blank?
      ses_data.each do |ses_result|
        unless ses_result[:preferred_term_id].blank?
          ses_fields.flatten.each do |sf|
            expanded_terms << "#{sf}:#{ses_result[:preferred_term_id]}" if ses_result[:preferred_term_id]
          end
        end
      end
    end

    expanded_terms
  end

  def group_unquoted_words_as_phrases(tokens)
    # iterates through tokens and groups all :unquoted_word tokens as :unquoted_phrases
    # while respecting the structure of the query relative to other terms
    ret = []
    unquoted_words = []

    tokens.each do |label, value|
      if label == :unquoted_word
        unquoted_words << value
      else
        # if the current token is not an unquoted word, merge all unquoted words in the buffer (if any) & label
        ret << [:unquoted_phrase, unquoted_words.join(" ")] unless unquoted_words.empty?
        unquoted_words = []
        # no operation necessary on other token types
        ret << [label, value]
      end
    end

    # finally, if there are any unquoted words left, combine them as a phrase
    ret << [:unquoted_phrase, unquoted_words.join(" ")] unless unquoted_words.empty?
    ret
  end
end
