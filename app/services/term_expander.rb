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

    if expanded_fields[:process_without_field] == true
      expanded_terms << handle_non_aliased_terms
    end

    unless expanded_fields[:text_fields].empty?
      expanded_terms << populate_text_fields
    end

    unless expanded_fields[:ses_id_fields].empty?
      expanded_terms << populate_ses_id_fields
    end

    unless expanded_fields[:boolean_fields].empty?
      expanded_terms << populate_boolean_fields
    end

    unless expanded_fields[:date_fields].empty?
      expanded_terms << populate_date_fields
    end

    unless expanded_fields[:ses_fields].empty?
      expanded_terms << populate_ses_fields
    end

    # combine all new search terms with OR
    expanded_terms.flatten.join(' OR ')
  end

  ##
  # Retrieve the preferred term and synonyms from SES data and apply them across all text fields
  # This is done iteratively as SES may return multiple terms with multiple equivalent terms each
  # Where preferred term is not present, apply the search term instead
  def populate_text_fields
    expanded_terms = []

    unless expanded_fields[:text_fields].blank?
      expanded_fields[:text_fields].flatten.each do |tf|
        ses_data.each do |ses_result|
          expanded_terms << (ses_result[:preferred_term].present? ? "#{tf}:\"#{ses_result[:preferred_term]}\"" : "#{tf}:\"#{search_term}\"")
          if ses_result[:equivalent_terms] && ses_result[:equivalent_terms].any?
            ses_result[:equivalent_terms].flatten.each do |et|
              expanded_terms << "#{tf}:\"#{et}\""
            end
          end
        end
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
        expanded_terms << "#{sif}:#{search_term}"
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
        expanded_terms << "#{df}:#{parsed_date}"
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
    ses_data.each do |ses_result|
      expanded_terms << (ses_result[:preferred_term].present? ? "\"#{ses_result[:preferred_term]}\"" : "\"#{search_term}\"")
      ses_result[:equivalent_terms].flatten.each do |et|
        expanded_terms << "\"#{et}\""
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
      ses_data.each do |ses_result|
        unless ses_result[:preferred_term_id].blank?
          expanded_fields[:ses_fields].flatten.each do |sf|
            expanded_terms << "#{sf}:#{ses_result[:preferred_term_id]}" if ses_result[:preferred_term_id]
          end
        end
      end
    end

    expanded_terms
  end
end
