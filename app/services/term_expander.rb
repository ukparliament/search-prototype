# frozen_string_literal: true

##
# Requires an array field categories, processed SES data and a search term.
# Returns a string that can substitute for the provided search term in a Solr query, returning expanded results.
class TermExpander
  attr_reader :expanded_fields, :ses_data, :search_term

  # Optional toggle; when true, unquoted phrases will be expanded via SES.
  EXPAND_UNQUOTED_PHRASES = ENV["EXPAND_UNQUOTED_PHRASES"] || Rails.application.credentials.dig(:expand_unquoted_phrases)

  def initialize(expanded_fields: {}, ses_data: [{}], search_term: nil)
    @expanded_fields = expanded_fields
    @ses_data = ses_data
    @search_term = search_term
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

    process_expanded_terms(expanded_terms)
  end

  def process_expanded_terms(expanded_terms)
    return if expanded_terms.empty?

    # group terms based on matching SES term or other ID
    grouped_terms_array = expanded_terms.flatten(1).group_by { |t| t.first.itself }.values

    # combine groups of terms as strings using 'OR'
    group_strings = grouped_terms_array.map { |gr| gr.map(&:last).flatten(1).join(' OR ') }

    # If only one string, return it
    return group_strings.first unless group_strings.size > 1

    # Otherwise, wrap strings in brackets and combine with 'AND'
    group_strings.map { |str| "(#{str})" }.join(' AND ')
  end

  ##
  # Retrieve the preferred term and synonyms from SES data and apply them across all text fields
  # This is done iteratively as SES may return multiple terms with multiple equivalent terms each
  # Where preferred term is not present, apply the search term instead
  def populate_text_fields
    expanded_terms = []
    represented_terms = []

    unless expanded_fields[:text_fields].blank?
      expanded_fields[:text_fields].flatten.each do |tf|
        ses_data.each do |ses_result|

          if ses_result[:preferred_term].present?
            result = ["#{tf}:\"#{ses_result[:preferred_term]}\""]
            represented_terms << ses_result[:preferred_term]
          else
            result = ["#{tf}:\"#{search_term}\""]
            represented_terms << search_term
          end

          if ses_result[:equivalent_terms] && ses_result[:equivalent_terms].any?
            ses_result[:equivalent_terms].flatten.each do |et|
              result << "#{tf}:\"#{et}\""
              represented_terms << et
            end
          end

          expanded_terms << [ses_result[:preferred_term_id], result]

        end

        # Add search terms not represented by SES responses to the query with their specified field
        search_term.downcase.split(" ").each do |search_word|
          unless represented_terms.join(" ").downcase.include?(search_word)
            expanded_terms << [search_word.to_sym, ["#{tf}:\"#{search_word}\""]]
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
    expanded_terms = []

    unless expanded_fields[:ses_id_fields].blank?
      expanded_fields[:ses_id_fields].flatten.each do |sif|
        expanded_terms << [:ses_id, "#{sif}:#{search_term}"]
      end
    end

    expanded_terms
  end

  ##
  # Search all boolean fields with '1' or '0' depending on entered term
  def populate_boolean_fields
    expanded_terms = []

    unless expanded_fields[:boolean_fields].blank?
      expanded_fields[:boolean_fields].flatten.each do |bf|
        if %w[true yes y 1].include?(search_term)
          expanded_terms << [:boolean, "#{bf}:1"]
        elsif %w[false no n 0].include?(search_term)
          expanded_terms << [:boolean, "#{bf}:0"]
        end
      end
    end

    expanded_terms
  end

  ##
  # Search across date fields based on the supplied alias
  def populate_date_fields
    expanded_terms = []

    unless expanded_fields[:date_fields].blank?
      date_lookup = {
        today: "NOW/DAY",
        yesterday: "NOW/DAY-1DAY",
        thisweek: "[NOW/WEEK TO NOW/WEEK+6DAYS]",
        lastweek: "[NOW/WEEK-1WEEK TO NOW/WEEK-1DAY]",
        thismonth: "[NOW/MONTH TO NOW/MONTH+1MONTH-1MILLISECOND]",
        lastmonth: "[NOW/MONTH-1MONTH TO NOW/MONTH-1MILLISECOND]",
        thisyear: "[NOW/YEAR TO NOW/YEAR+1YEAR-1MILLISECOND]",
        lastyear: "[NOW/YEAR-1YEAR TO NOW/YEAR-1MILLISECOND]"
      }

      parsed_date = date_lookup[search_term&.to_sym].nil? ? search_term : date_lookup[search_term&.to_sym]
      expanded_fields[:date_fields].flatten.each do |df|
        expanded_terms << [:date, "#{df}:#{parsed_date}"]
      end

    end

    expanded_terms
  end

  ##
  # Where no alias was given, the search term is replaced with the preferred term if present, and expanded
  # further with equivalent terms, if present.
  # This is done iteratively as SES may return multiple terms with multiple equivalent terms each.
  def handle_non_aliased_terms
    expanded_terms = []

    # Where we do have SES data, iterate through the SES results and use them (via SES ID) to create tagged sets
    # of expanded terms (pulling in equivalent term data).
    ses_data.each do |ses_result|
      result = [ses_result[:preferred_term].present? ? "\"#{ses_result[:preferred_term]}\"" : "\"#{search_term}\""]

      ses_result[:equivalent_terms].flatten.each do |et|
        result << "\"#{et}\""
      end

      expanded_terms << [ses_result[:preferred_term_id], result]
    end

    # TODO: this logic might also be required for quoted phrases & aliased quoted phrases?
    # TODO: exhaustively test that this approach works

    # create a string of all the expanded terms so far
    all_expanded_terms = expanded_terms.to_h.values.flatten.join(" ").downcase

    # check each word is represented by something we got back from SES
    search_term.downcase.split(" ").each do |search_word|
      unless all_expanded_terms.include?(search_word)
        expanded_terms << [search_word.to_sym, ["\"#{search_word}\""]]
      end
    end

    expanded_terms
  end

  ##
  # Search all SES fields with the preferred term ID, if present.
  # SES data may return multiple terms, so this is done iteratively.
  def populate_ses_fields
    expanded_terms = []

    # add every SES field we've determined should be searched for the preferred term SES ID
    unless expanded_fields[:ses_fields].blank? || ses_data.blank?
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

    expanded_terms
  end
end
