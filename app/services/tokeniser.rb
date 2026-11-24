# frozen_string_literal: true

##
# Tokeniser processes a query string into an array of labelled tokens.
class Tokeniser
  attr_reader :query

  def initialize(query)
    @query = query
  end

  ##
  # TOKEN_REGEX is used to scan query strings and put matches into buckets we can add token labels to:
  #
  # Bucket 0: Opening parenthesis (
  # Bucket 1: Closing parenthesis )
  # Bucket 2: Solr boolean operators AND OR
  # Bucket 3: Solr modifier operators NOT + -
  # Bucket 4: Wildcards (*) for retrieval of all records
  # Bucket 5: http://.... or similar
  # Bucket 6: uri:http://... or similar
  # Bucket 7: field_name:"term"
  # Bucket 8: field_name:'term'
  # Bucket 9: field_name:[phrase in square brackets]
  # Bucket 10: field_name:*
  # Bucket 11: field_name:term
  # Bucket 12: [phrase in square brackets]
  # Bucket 13: Opening bracket [
  # Bucket 14: Closing bracket ]
  # Bucket 15: "double-quoted phrase"
  # Bucket 16: 'single-quoted phrase'
  # Bucket 17: unquoted term
  TOKEN_REGEX = /(\()|(\))|(AND|OR)|(NOT|-|\+)|(\*:\*)|([a-z]+:\/\/\S+)|(uri:[a-z]+:\/\/\S+)|(\w+:"(?:[^"]+)")|(\w+:'(?:[^']+)')|(\w+:\[(?:[^\]]+)\])|(\w+:\*)|(\w+:\S+)|(\[(?:[^\]]+)\])|(\[)|(\])|"([^"]+)"|'([^']+)'|([^\s()\[\]{}:"^~!]+)/

  ##
  # Terms operates on the provided query string, returning an array of separate string 'terms' for tokenisation:
  # - Returns nil if no query is provided
  def terms
    return if query.blank?

    puts "query: #{query}" if Rails.env.development? || Rails.env.test?
    ret = query.to_s.scan(TOKEN_REGEX)
    puts "scan results: #{ret}" if Rails.env.development? || Rails.env.test?
    ret
  end

  ##
  # Tokenise operates on the result of the term extraction process and assigns a token label based on the position
  # of the matcher in the regex used for term extraction.
  #
  # The final step groups any adjacent unquoted words in the array into phrases before being returned.
  def tokenise
    tokens = []

    terms.each do |term|
      puts "Processing scan fragment: #{term}" if Rails.env.development? || Rails.env.test?

      term.each_with_index do |matched_term, i|
        next if matched_term.nil?

        case i
        when 0
          tokens << QueryToken.new(type: :opening_parenthesis, value: matched_term)
        when 1
          tokens << QueryToken.new(type: :closing_parenthesis, value: matched_term)
        when 2
          tokens << QueryToken.new(type: :boolean_operator, value: matched_term)
        when 3
          tokens << QueryToken.new(type: :modifier_operator, value: matched_term)
        when 4
          tokens << QueryToken.new(type: :all_records, value: matched_term)
        when 5
          tokens << QueryToken.new(type: :url, value: matched_term)
        when 6
          tokens << QueryToken.new(type: :uri_field, value: matched_term)
        when 7, 8
          tokens << QueryToken.new(type: :specified_field_with_quoted_phrase, value: matched_term)
        when 9
          tokens << QueryToken.new(type: :specified_field_no_expansion, value: matched_term)
        when 10
          tokens << QueryToken.new(type: :specified_field_wildcard, value: matched_term)
        when 11
          tokens << QueryToken.new(type: :specified_field, value: matched_term)
        when 12
          tokens << QueryToken.new(type: :no_expansion, value: matched_term)
        when 13
          tokens << QueryToken.new(type: :opening_bracket, value: matched_term)
        when 14
          tokens << QueryToken.new(type: :closing_bracket, value: matched_term)
        when 15, 16
          tokens << QueryToken.new(type: :quoted_phrase, value: matched_term)
        when 17
          tokens << QueryToken.new(type: :unquoted_word, value: matched_term)
        else
          puts "Term not matched by tokeniser: #{matched_term}" if Rails.env.development? || Rails.env.test?
          next
        end
      end
    end

    tokens
  end
end