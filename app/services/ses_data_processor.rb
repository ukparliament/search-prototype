##
# SesDataProcessor is a class used to filter returned SES data. It requires:
# - a collection of terms returned from SES
# - the initial query string
# - a query string processing class
#
# The SES endpoint we are using returns everything that matches any
# aspect of the search, which is very useful for picking up on multi-word
# concepts buried within longer user-submitted strings, but the results
# then require some pruning.
# This class performs a number of string-matching checks and removes
# failing terms from the response before they reach term expansion.

class SesDataProcessor

  attr_reader :terms, :query_string, :query_string_processor, :exact_match_required

  def initialize(terms: [], query_string: nil, query_string_processor: QueryStringProcessor, exact_match_required: false)
    @terms = terms
    @query_string = query_string
    @query_string_processor = query_string_processor
    @exact_match_required = exact_match_required
  end

  ##
  # iterate through all terms and filter them
  def process_terms
    puts "SesTermFilter#process_terms" if Rails.env.development? || Rails.env.test?

    processed_query_array = generate_sequential_combinations
    puts "PCA: #{processed_query_array}" if Rails.env.development? || Rails.env.test?
    returned_terms = []

    terms.each do |term|
      # skip topic terms
      next if term_is_topic_term(term)

      term_matches_query = false
      term_hash = populate_term_hash(term)

      # skip if there's no exact match in exact-match-mode
      next if exact_match_required && !contains_exact_match?(query_string, term_hash)

      # create a simple flat array version of the terms & iterate through them
      all_synonyms = [term_hash[:preferred_term], term_hash[:equivalent_terms]].flatten.compact
      # puts "all_synonyms: #{all_synonyms}" if Rails.env.development? || Rails.env.test?
      all_synonyms.each do |term_or_synonym|
        # skip unless the term is present in the query
        next unless processed_query_array.include?(term_or_synonym.downcase)


        # set the term match boolean flag to true & delete from processed_query_array
        term_matches_query = true
        processed_query_array = filter_term(term_or_synonym, processed_query_array)
      end

      # if there's no match, skip to the next term
      next unless term_matches_query

      # otherwise, put the term_hash into returned terms array
      returned_terms << term_hash
    end

    returned_terms
  end

  private

  ##
  # Filter the processed_query_array to remove a provided term
  # Also remove all sub-terms (generated using query string processor)
  # and fragments (by splitting on spaces)
  # Then returns updated version of processed_query_array
  def filter_term(term_to_remove, processed_query_array)
    puts "Filtering term: #{term_to_remove}"

    # delete the match from the array
    processed_query_array.delete(term_to_remove.downcase)

    # generate and delete all sub terms for the match
    sub_terms = query_string_processor.new(term_to_remove).sequential_combinations
    sub_terms.each do |sub_term|
      processed_query_array.delete(sub_term.downcase)
    end

    # generate and delete all term fragments for the match
    fragments = term_to_remove.downcase.split(" ")
    fragments.each do |fragment|
      processed_query_array.each do |query_term|
        processed_query_array.delete(query_term) if query_term.include?(fragment)
      end
    end

    # return the updated array
    processed_query_array
  end

  ##
  # Identify topic terms (unwanted) by class string
  def term_is_topic_term(term)
    term.dig("term", "class") == "TPG"
  end

  ##
  # Accepts a term (one of the data objects returned by SES)
  # Returns a simple hash containing only the data we need for our purposes
  def populate_term_hash(term)
    # create hash for the term data
    term_hash = { equivalent_terms: [] }

    # fetch preferred term name and ID
    # SES responds with the preferred term regardless of whether the search matched preferred or non-preferred term
    term_hash[:preferred_term] = term.dig("term", "name")
    term_hash[:preferred_term_id] = term.dig("term", "id")

    # equivalent terms might not be present
    if term.dig("term").has_key?("equivalence")
      term_hash[:equivalent_terms] = term.dig("term", "equivalence").select { |ec| ec["typeId"] == "3" }.dig(0, "fields").map { |f| f.dig("field", "name") }
    end

    term_hash
  end

  ##
  # Boolean method, returns true if there's an exact match for a query term in the term hash
  # This can be the preferred term or one of the equivalent terms
  # Otherwise returns false
  def contains_exact_match?(query_string, term_hash)
    query_string.downcase == term_hash[:preferred_term].downcase || term_hash[:equivalent_terms].map(&:downcase).include?(query_string.downcase)
  end

  ##
  # Create an instance of the query_string_processor class and pass in the query string
  # The sequential combinations method returns an array of all possible sequential substrings
  # This is our 'processed query array'
  def generate_sequential_combinations
    query_string_processor.new(query_string).sequential_combinations
  end
end