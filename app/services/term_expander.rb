# frozen_string_literal: true

##
# Requires an array field categories, processed SES data and a search term.
# An instance of this class is initialised for each processed token that requires expansion.
# Returns a string that can substitute for the provided search term in a Solr query, returning expanded results.
class TermExpander
  attr_reader :expanded_fields, :ses_data, :search_term, :exact_match

  DATE_LOOKUP = {
    today: "NOW/DAY",
    yesterday: "NOW/DAY-1DAY",
    thisweek: "[NOW/WEEK TO NOW/WEEK+6DAYS]",
    lastweek: "[NOW/WEEK-1WEEK TO NOW/WEEK-1DAY]",
    thismonth: "[NOW/MONTH TO NOW/MONTH+1MONTH-1MILLISECOND]",
    lastmonth: "[NOW/MONTH-1MONTH TO NOW/MONTH-1MILLISECOND]",
    thisyear: "[NOW/YEAR TO NOW/YEAR+1YEAR-1MILLISECOND]",
    lastyear: "[NOW/YEAR-1YEAR TO NOW/YEAR-1MILLISECOND]"
  }

  def initialize(expanded_fields: {}, ses_data: [], search_term: nil, exact_match: false)
    @expanded_fields = expanded_fields
    @ses_data = ses_data
    @search_term = search_term
    @exact_match = exact_match
  end

  ##
  # Populates expanded terms array by operating on each of the categories within the  expanded_fields hash in turn.
  # Combine contents of expanded terms array into a single query string using 'OR'. The output is suitable for
  # substitution into a Solr query in place of the :search_term provided to this class.
  def expand_terms
    expanded_terms = []
    expanded_terms << handle_non_aliased_terms if expanded_fields[:process_without_field] == true
    expanded_terms << populate_text_fields unless expanded_fields[:text_fields].empty?
    expanded_terms << populate_ses_id_fields unless expanded_fields[:ses_id_fields].empty?
    expanded_terms << populate_boolean_fields unless expanded_fields[:boolean_fields].empty?
    expanded_terms << populate_date_fields unless expanded_fields[:date_fields].empty?
    expanded_terms << populate_ses_fields unless expanded_fields[:ses_fields].empty?
    expanded_terms << populate_fixed_fields unless expanded_fields[:fixed_fields].empty?
    expanded_terms << apply_transformations unless expanded_fields[:transformations].empty?

    process_expanded_terms(expanded_terms)
  end

  def process_expanded_terms(expanded_terms)
    return if expanded_terms.empty?

    puts "Expanded terms: #{expanded_terms}" if Rails.env.development? || Rails.env.test?

    # group terms based on matching SES term or other ID
    grouped_terms_array = expanded_terms.flatten(1).group_by { |t| t.first.itself }.values

    # then combine the groups with 'OR' operators to produce an array of query string fragments
    group_strings = grouped_terms_array.map { |grouped_terms| grouped_terms.map(&:last).flatten(1).join(' OR ') }

    # If only one string in the resulting array, return it
    return group_strings.first unless group_strings.size > 1

    # If there are multiple strings, combine them with and
    # Any strings that have spaces in have multiple internal terms so wrap those in brackets first
    group_strings.map { |str| str.split(" ").size > 1 ? "(#{str})" : "#{str}" }.join(' AND ')
  end

  ##
  # Retrieve the preferred term and synonyms from SES data and apply them across all text fields
  # This is done iteratively as SES may return multiple terms with multiple equivalent terms each
  # Where preferred term is not present, apply the search term instead
  def populate_text_fields
    puts "TermExpander#populate_text_fields" if Rails.env.development? || Rails.env.test?
    expanded_terms = []
    represented_terms = []

    unless expanded_fields[:text_fields].blank?
      expanded_fields[:text_fields].flatten.each do |tf|
        ses_data.each do |ses_result|
          if ses_result[:preferred_term].present?
            result = ["#{tf}:#{conditionally_quoted(ses_result[:preferred_term])}"]
            represented_terms << ses_result[:preferred_term]
          else
            result = ["#{tf}:#{conditionally_quoted(search_term)}"]
            represented_terms << search_term
          end

          if ses_result[:equivalent_terms] && ses_result[:equivalent_terms].any?
            ses_result[:equivalent_terms].flatten.each do |et|
              result << "#{tf}:#{conditionally_quoted(et)}"
              represented_terms << et
            end
          end

          expanded_terms << [ses_result[:preferred_term_id], result]
        end

        # build list of terms that should be represented in the final query somehow
        # in exact_match mode, this is just the whole search term as one chunk
        # otherwise, we split on spaces
        if exact_match
          terms_to_represent = [search_term]
        else
          terms_to_represent = search_term.split(" ")
        end

        puts "Terms to represent: #{terms_to_represent}" if Rails.env.development? || Rails.env.test?

        # Add search terms not represented by SES responses to the query with their specified field
        terms_to_represent.each do |search_word|
          unless represented_terms.join(" ").downcase.include?(search_word.downcase)
            # search words don't have spaces (as we split on them) so we don't need to conditionally quote them
            expanded_terms << [search_word.to_sym, ["#{tf}:#{conditionally_quoted(search_word)}"]]
          end
        end

        expanded_terms

      end
    end

    expanded_terms
  end

  ##
  # Search all SES ID fields with the SES ID provided as a search term.
  def populate_ses_id_fields
    puts "TermExpander#populate_ses_id_fields" if Rails.env.development? || Rails.env.test?
    expanded_terms = []

    unless expanded_fields[:ses_id_fields].blank?
      expanded_fields[:ses_id_fields].flatten.each do |sif|
        expanded_terms << [:ses_id, "#{sif}:#{search_term}"]
      end
    end

    expanded_terms
  end

  ##
  # Simple input transformations (field specific)
  def apply_transformations
    puts "TermExpander#apply_transformations" if Rails.env.development? || Rails.env.test?
    expanded_terms = []

    unless expanded_fields[:transformations].blank?

      expanded_fields[:transformations].flatten.each do |tf|
        case tf
        when 'session'
          expanded_terms << [:session, "session_s:#{expand_session_string(search_term)}"]
        when 'timestamp'
          expanded_terms << [:timestamp, "timestamp:#{format_as_utc_time(search_term)}"]
        when 'status'
          expanded_terms << [:status, "edmStatus_s:#{search_term&.titleize}"]
          expanded_terms << [:status, "pqStatus_s:#{search_term&.titleize}"]
          expanded_terms << [:status, "status_s:#{search_term&.titleize}"]
        else
          raise QueryExpansionError, "Unknown transformation type \"#{tf}\""
        end
      end

      expanded_terms
    end

  end

  ##
  # Arbitrary logic for a few odd fields
  def populate_fixed_fields
    puts "TermExpander#populate_fixed_fields" if Rails.env.development? || Rails.env.test?
    expanded_terms = []

    unless expanded_fields[:fixed_fields].blank?
      expanded_fields[:fixed_fields].flatten.each do |ff|
        case ff
        when 'chair'
          if search_term_is_true?
            expanded_terms << [:ses_id, "member_ses:303704"] # TODO: expose in config
          elsif search_term_is_false?
            expanded_terms << [:ses_id, "-member_ses:303704"]
          end
        when 'fromdate'
          expanded_terms << [:date, "date_dt:#{format_as_utc_time(search_term, day_as_range: false)} TO *"]
        when 'todate'
          expanded_terms << [:date, "* TO date_dt:#{format_as_utc_time(search_term, day_as_range: false)}"]
        when 'opqtype'
          if search_term == 'supp'
            expanded_terms << [:text, "contributionType_t:supplementary"]
          elsif search_term == 'othersupp'
            expanded_terms << [:text, "contributionType_s:Supplementary"]
          elsif search_term == 'firstsupp'
            expanded_terms << [:text, "contributionType_s:\"1st Supplementary\""]
          elsif search_term == 'lead'
            expanded_terms << [:text, "contributionType_s:Lead"]
          end
        when 'wpqtype'
          if search_term == 'ordinary'
            expanded_terms << [:text, "wpqType_s:Ordinary"]
          elsif search_term == 'namedday'
            expanded_terms << [:text, "wpqType_s:Named Day"]
          elsif search_term == 'nextday'
            expanded_terms << [:text, "wpqType_s:daily"]
          end
        else
          next
        end

      end

      # Return expanded terms
      expanded_terms
    end
  end

  ##
  # Search all boolean fields with '1' or '0' depending on entered term
  def populate_boolean_fields
    puts "TermExpander#populate_boolean_fields" if Rails.env.development? || Rails.env.test?
    expanded_terms = []

    unless expanded_fields[:boolean_fields].blank?
      expanded_fields[:boolean_fields].flatten.each do |bf|
        if search_term_is_true?
          expanded_terms << [:boolean, "#{bf}:1"]
        elsif search_term_is_false?
          expanded_terms << [:boolean, "#{bf}:0"]
        elsif search_term == "*"
          expanded_terms << [:boolean, "#{bf}:*"]
        end
      end
    end

    expanded_terms
  end

  ##
  # Search across date fields based on the supplied alias
  # Supports field-exists queries using *
  def populate_date_fields
    puts "TermExpander#populate_date_fields" if Rails.env.development? || Rails.env.test?
    expanded_terms = []

    unless expanded_fields[:date_fields].blank?
      expanded_fields[:date_fields].flatten.each do |df|
        expanded_terms << [:date, "#{df}:#{parse_date(search_term)}"]
      end
    end

    expanded_terms
  end

  def parse_date(date)
    DATE_LOOKUP[date&.downcase&.to_sym].nil? ? date : DATE_LOOKUP[date&.downcase&.to_sym]
  end

  ##
  # Where no alias was given, the search term is replaced with the preferred term if present, and expanded
  # further with equivalent terms, if present.
  # This is done iteratively as SES may return multiple terms with multiple equivalent terms each.
  def handle_non_aliased_terms
    puts "TermExpander#handle_non_aliased_terms" if Rails.env.development? || Rails.env.test?
    expanded_terms = []

    # Where we do have SES data, iterate through the SES results and use them (via SES ID) to create tagged sets
    # of expanded terms (pulling in equivalent term data).
    ses_data&.each do |ses_result|
      result = []

      # determine whether we use the preferred term or original search term
      if ses_result[:preferred_term].present?
        result << conditionally_quoted(ses_result[:preferred_term])
      else
        result << conditionally_quoted(search_term)
      end

      # wrap each equivalent term in quotes if needed
      ses_result[:equivalent_terms].flatten.each do |et|
        result << conditionally_quoted(et)
      end

      # return the resulting array tagged with the preferred term ID
      expanded_terms << [ses_result[:preferred_term_id], result]
    end

    if exact_match
      terms_to_represent = [search_term]
    else
      terms_to_represent = search_term.split(" ")
    end

    puts "Terms to represent: #{terms_to_represent}" if Rails.env.development? || Rails.env.test?

    terms_to_represent.each do |search_word|
      puts "Checking that '#{search_word}' is represented in query as expanded" if Rails.env.development? || Rails.env.test?

      if exact_match
        # In exact mode, the term must match exactly with a distinct SES term
        search_word_matched = false

        # iterate through expanded terms and check each one against the search word
        expanded_terms.to_h.values.flatten.each do |expanded_term|
          if search_word.downcase.include?(expanded_term.downcase)
            search_word_matched = true
          end
        end

        # if none of them matched, add the search word back into the query
        unless search_word_matched
          puts "Not represented! Adding." if Rails.env.development? || Rails.env.test?
          expanded_terms << [search_word.to_sym, ["#{search_word}"]]
        end
      else
        # In non-exact mode, we just check that the word is included somewhere in the combined string of SES terms

        # create a string of all the expanded terms so far
        all_expanded_terms = expanded_terms.to_h.values.flatten.join(" ").downcase

        # if the search word isn't included, add it back into the query

        unless all_expanded_terms.include?(search_word.downcase.delete_prefix('"').delete_suffix('"'))
          puts "Not represented! Adding." if Rails.env.development? || Rails.env.test?
          expanded_terms << [search_word.to_sym, ["#{search_word}"]]
        end
      end

    end

    expanded_terms
  end

  ##
  # Search all SES fields with the preferred term ID, if present.
  # SES data may return multiple terms, so this is done iteratively.
  #
  # Note that this differs from 'populate_ses_id_fields' because here the user hasn't provided a SES ID; we've gone
  # to SES with a user provided term and fetched SES IDs, which we're now using to search one or more SES fields.
  def populate_ses_fields
    puts "TermExpander#populate_ses_fields" if Rails.env.development? || Rails.env.test?
    expanded_terms = []

    unless expanded_fields[:ses_fields].blank?
      # check for & process field-exists operator
      if search_term.present? && search_term == "*"
        result = []

        expanded_fields[:ses_fields].flatten.each do |sf|
          result << "#{sf}:*"
        end

        expanded_terms << [search_term.to_sym, result]
      end

      # TODO: some SES fields (e.g. topic_ses!) will require ses_data to include topics
      #   This will involve modifying our SES API calls to allow conditional retrieval of TPG terms
      unless ses_data.blank?
        ses_data.each_with_index do |ses_result, index|
          # If there's no preferred term ID, don't return anything for this result
          next if ses_result[:preferred_term_id].blank?

          result = []
          expanded_fields[:ses_fields].flatten.each do |sf|
            result << "#{sf}:#{ses_result[:preferred_term_id]}" if ses_result[:preferred_term_id]
          end

          expanded_terms << [ses_result[:preferred_term_id], result]
        end
      end
    end

    expanded_terms
  end

  private

  def search_term_is_true?
    return unless search_term.present?

    %w[true yes y 1].include?(search_term.downcase)
  end

  def search_term_is_false?
    return unless search_term.present?

    %w[false no n 0].include?(search_term.downcase)
  end

  def conditionally_quoted(string)
    string.include?(" ") ? "\"#{string}\"" : string
  end

  def expand_session_string(search_term)
    case search_term
    when /\A(\d{2})[\/\-&:](\d{2})\z/
      # 19/20
      if search_term.first(2).to_i < (Date.current.year + 1) % 100
        "20#{search_term.first(2)}-#{search_term.last(2)}"
      else
        "19#{search_term.first(2)}-#{search_term.last(2)}"
      end
    end
  end

  def format_as_utc_time(search_term, day_as_range: true)
    if search_term.split("..").size > 1
      # the user provided a date range using ".."
      range_components = search_term.split("..")
      range_start = parse_as_utc_time(range_components.first.strip)
      range_end = parse_as_utc_time(range_components.last.strip, offset_days: 1.day)
      format_as_solr_date_range(range_start, range_end, inclusive_end: false)
    elsif search_term.split(" TO ").size > 1
      # the user provided a date range using " TO "
      range_components = search_term.split(" TO ")
      range_start = parse_as_utc_time(range_components.first.strip)
      range_end = parse_as_utc_time(range_components.last.strip, offset_days: 1.day)
      format_as_solr_date_range(range_start, range_end, inclusive_end: false)
    else
      # the user provided a single date
      if day_as_range
        # we construct a range representing the entire day
        range_start = parse_as_utc_time(search_term.strip)
        range_end = parse_as_utc_time(search_term.strip, offset_days: 1.day)
        format_as_solr_date_range(range_start, range_end, inclusive_end: false)
      else
        parse_as_utc_time(search_term.strip)
      end
    end
  end

  def format_as_solr_date_range(start_date, end_date, inclusive_start: true, inclusive_end: true)
    opening_bracket = inclusive_start ? "[" : "{"
    closing_bracket = inclusive_end ? "]" : "}"

    "#{opening_bracket}#{start_date} TO #{end_date}#{closing_bracket}"
  end

  def parse_as_utc_time(date_string, offset_days: 0.days)
    if date_string == "*"
      date_string
    elsif DATE_LOOKUP.has_key?(date_string&.downcase&.to_sym)
      # support for Solr date-adjacent terminology, e.g. "YESTERDAY TO TODAY"
      parse_date(date_string)
    else
      date = Date.iso8601(date_string)
      time = Time.utc(date.year, date.month, date.day) + offset_days
      time.iso8601
    end
  end
end
