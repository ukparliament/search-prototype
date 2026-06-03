# frozen_string_literal: true

##
# QueryExpander is an orchestration class to handle the query expansion process:
#
# - Accepts a search query which is passed on to the tokeniser.
#
# - The returned tokens are then processed iteratively:
#   - Expanded terms are obtained through the ses_query class.
#   - Expanded fields are obtained through the field_expander class.
#   - The above information is passed to the term_expander class to obtain an expanded query string for the term
#     represented by the token.
#   - The token is added to a processed_tokens array.
#
# - Finally, the processed tokens array is passed to the term_combiner class to combine all terms into a fully
# assembled expanded query string, which is then returned.

class QueryExpander
  attr_reader :search_query, :ses_query, :tokeniser, :field_expander, :term_expander, :term_combiner

  # matches Lucene query characters, captured as group 1
  SPECIAL_CHARS = /([+\-!(){}\[\]^"~:\\\/]|&&|\|\|)/

  def initialize(search_query, ses_query = SesQuery, tokeniser = Tokeniser,
                 field_expander = FieldExpander, term_expander = TermExpander, term_combiner = TermCombiner)
    @search_query = search_query
    @ses_query = ses_query
    @tokeniser = tokeniser
    @field_expander = field_expander
    @term_expander = term_expander
    @term_combiner = term_combiner
  end

  # TODO: refactor out basic string processing to private methods
  def expand_query
    tokens = tokeniser.new(search_query).tokenise
    processed_tokens = []

    puts "Tokens: #{tokens}" if Rails.env.development? || Rails.env.test?

    tokens.each do |label, value|
      puts "Processing token: #{label}: #{value}" if Rails.env.development? || Rails.env.test?

      if label == :operator
        processed_tokens << process_operator_token(value)
      elsif label == :parenthesis
        processed_tokens << process_parenthesis_token(value)
      elsif label == :url
        processed_tokens << process_url_token(value)
      elsif label == :uri_field
        processed_tokens << process_uri_field_token(value)
      elsif label == :specified_field_with_quoted_phrase
        processed_tokens << process_specified_field_with_quoted_phrase_token(value)
      elsif label == :specified_field_no_expansion
        processed_tokens << process_specified_field_no_expansion_token(value)
      elsif label == :specified_field_wildcard
        processed_tokens << process_specified_field_wildcard_token(value)
      elsif label == :specified_field
        processed_tokens << process_specified_field_token(value)
      elsif label == :quoted_phrase
        processed_tokens << process_quoted_phrase_token(value)
      elsif label == :no_expansion
        processed_tokens << process_no_expansion_token(value)
      elsif label == :unquoted_phrase
        processed_tokens << process_unquoted_phrase_token(value)
      else
        puts "Unmatched token type #{label} for #{value}" if Rails.env.development? || Rails.env.test?
        next
      end
      puts "Processed tokens: #{processed_tokens}" if Rails.env.development? || Rails.env.test?
    end

    puts "Final Processed tokens: #{processed_tokens}" if Rails.env.development? || Rails.env.test?
    term_combiner.new(processed_tokens).combine_terms
  end

  private

  def process_unquoted_phrase_token(value)
    search_term = value
    expanded_fields = field_expander.new("none").expand_fields
    ses_data = ses_query.new({ value: search_term }).data
    term_expander.new(expanded_fields: expanded_fields, ses_data: ses_data, search_term: search_term).expand_terms
  end

  def process_no_expansion_token(value)
    value.delete_prefix("[").delete_suffix("]")
  end

  def process_quoted_phrase_token(value)
    puts "Processing quoted phrase token: #{value}" if Rails.env.development? || Rails.env.test?

    expanded_fields = field_expander.new("none").expand_fields
    ses_data = ses_query.new({ value: value }, exact_match: true).data

    # the value will have been stripped of its quotes, so we need to reintroduce those
    search_term = "\"#{value}\""

    # Exact match should be true for quoted phrases
    term_expander.new(expanded_fields: expanded_fields, ses_data: ses_data, search_term: search_term, exact_match: true).expand_terms
  end

  def process_specified_field_token(value)
    search_term = value.partition(":").last
    field_name = value.partition(":").first
    expanded_fields = field_expander.new(field_name).expand_fields
    ses_data = ses_query.new({ value: search_term }).data
    term_expander.new(expanded_fields: expanded_fields, ses_data: ses_data, search_term: search_term).expand_terms
  end

  def process_specified_field_wildcard_token(value)
    # where the user has specified a wildcard with a field or alias we:
    # - perform field expansion
    # - don't perform term expansion
    # 
    search_term = value.partition(":").last
    field_name = value.partition(":").first
    expanded_fields = field_expander.new(field_name).expand_fields
    term_expander.new(expanded_fields: expanded_fields, search_term: search_term).expand_terms
  end

  def process_specified_field_no_expansion_token(value)
    # delete unwanted []; expand fields using blank SES data
    search_term = value.partition(":").last.delete_prefix("[").delete_suffix("]")
    field_name = value.partition(":").first
    expanded_fields = field_expander.new(field_name).expand_fields

    term_expander.new(expanded_fields: expanded_fields, search_term: search_term).expand_terms
  end

  def process_specified_field_with_quoted_phrase_token(value)
    # For quoted phrases, the user expectation is that the phrase is passed to Solr as-is
    # However, if the complete phrase is matched by SES, we search for that instead
    # strip one layer of quotes before continuing

    search_term = value.partition(":").last.delete_prefix('"').delete_suffix('"')
    field_name = value.partition(":").first

    ses_data = ses_query.new({ value: search_term }, exact_match: true).data
    expanded_fields = field_expander.new(field_name).expand_fields

    term_expander.new(expanded_fields: expanded_fields, ses_data: ses_data, search_term: search_term, exact_match: true).expand_terms
  end

  def process_uri_field_token(value)
    search_term = value.partition(":").last.gsub(SPECIAL_CHARS, '\\\\\1')
    field_name = value.partition(":").first

    "#{field_name}:#{search_term}"
  end

  def process_url_token(value)
    # If Solr receives a bunch of special characters it will indiscriminately escape them all itself, which
    # has the unfortunate side effect of wildcard (* and ?) characters being parsed as text only. We need to
    # escape special characters (except wildcards) before submitting the search.
    value.gsub(SPECIAL_CHARS, '\\\\\1')
  end

  def process_operator_token(value)
    # No processing required for operators
    value
  end

  def process_parenthesis_token(value)
    # No processing required for brackets
    value
  end

end