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

    puts "Tokens: #{tokens}" if Rails.env.development?

    tokens.each do |label, value|
      puts "Processing token: #{label}: #{value}" if Rails.env.development?

      if label == :operator
        # do nothing, pass directly to Solr
        search_term = value
        processed_tokens << search_term
      elsif label == :url
        # If Solr receives a bunch of special characters it will indiscriminately escape them all itself, which
        # has the unfortunate side effect of wildcard (* and ?) characters being parsed as text only. We need to
        # escape special characters (except wildcards) before submitting the search.
        search_term = value.gsub(SPECIAL_CHARS, '\\\\\1')
        processed_tokens << search_term
      elsif label == :uri_field
        search_term = value.partition(":").last.gsub(SPECIAL_CHARS, '\\\\\1')
        field_name = value.partition(":").first
        processed_tokens << "#{field_name}:#{search_term}"
      elsif label == :specified_field_with_quoted_phrase
        # For quoted phrases, the user expectation is that the phrase is passed to Solr as-is
        # However, if the complete phrase is matched by SES, we search for that instead
        # strip one layer of quotes before continuing
        search_term = value.partition(":").last.delete_prefix('"').delete_suffix('"')
        field_name = value.partition(":").first
        ses_data = ses_query.new({ value: search_term }).data
        expanded_fields = field_expander.new(field_name).expand_fields

        # TODO: needs to only match on full phrase? To confirm
        processed_tokens << term_expander.new(expanded_fields: expanded_fields,
                                              ses_data: ses_data,
                                              search_term: search_term).expand_terms

      elsif label == :specified_field_no_expansion
        # delete unwanted []; expand fields using blank SES data
        search_term = value.partition(":").last.delete_prefix("[").delete_suffix("]")
        field_name = value.partition(":").first
        expanded_fields = field_expander.new(field_name).expand_fields
        processed_tokens << term_expander.new(expanded_fields: expanded_fields, search_term: search_term).expand_terms

      elsif label == :specified_field_wildcard
        # where the user has specified a wildcard with a field or alias we:
        # - perform field expansion
        # - don't perform term expansion
        search_term = value.partition(":").last
        field_name = value.partition(":").first
        expanded_fields = field_expander.new(field_name).expand_fields
        processed_tokens << term_expander.new(expanded_fields: expanded_fields,
                                              search_term: search_term).expand_terms

      elsif label == :specified_field
        search_term = value.partition(":").last
        field_name = value.partition(":").first
        expanded_fields = field_expander.new(field_name).expand_fields
        ses_data = ses_query.new({ value: search_term }).data
        processed_tokens << term_expander.new(expanded_fields: expanded_fields,
                                              ses_data: ses_data,
                                              search_term: search_term).expand_terms

      elsif label == :quoted_phrase
        search_term = value
        expanded_fields = field_expander.new("none").expand_fields
        ses_data = ses_query.new({ value: search_term }).data
        processed_tokens << term_expander.new(expanded_fields: expanded_fields,
                                              ses_data: ses_data,
                                              search_term: search_term).expand_terms

      elsif label == :no_expansion
        search_term = value.delete_prefix("[").delete_suffix("]")
        processed_tokens << search_term

      elsif label == :unquoted_phrase
        search_term = value
        expanded_fields = field_expander.new("none").expand_fields
        ses_data = ses_query.new({ value: search_term }).data if TermExpander::EXPAND_UNQUOTED_PHRASES
        processed_tokens << term_expander.new(expanded_fields: expanded_fields,
                                              ses_data: ses_data,
                                              search_term: search_term).expand_terms
      else
        puts "Unmatched token type #{label} for #{value}" if Rails.env.development?
        next
      end
    end

    term_combiner.new(processed_tokens).combine_terms
  end
end