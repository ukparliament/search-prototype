# frozen_string_literal: true

##
# Tokeniser processes a query string into an array of labelled tokens.
class Tokeniser
  attr_reader :query

  def initialize(query)
    @query = query
  end

  # TODO: break down complex tokens into simple ones
  ##
  # TOKEN_REGEX is used to scan query strings and put matches into buckets we can add token labels to:

  # Bucket 0: Opening parenthesis (
  # Bucket 1: Closing parenthesis )
  # Bucket 2: Solr boolean operators AND OR
  # Bucket 3: Solr modifier operators NOT + -
  # Bucket 4: HTTPS scheme
  # Bucket 5: HTTP scheme
  # Bucket 6: Wildcard *
  # Bucket 7: Colon :
  # Bucket 8: Opening bracket [
  # Bucket 9: Closing bracket ]
  # Bucket 10: Double quote "
  # Bucket 11: Single quote '
  # Bucket 12: Strings excluding various symbols (allows _)
  TOKEN_REGEX = /(\()|(\))|(AND|OR)|(NOT|-|\+)|(https:\/\/)|(http:\/\/)|(\*)|(:)|(\[)|(\])|(")|(')|([^\s()\[\]{}:"'^~!]+)/

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
          tokens << QueryToken.new(type: :https_scheme, value: matched_term)
        when 5
          tokens << QueryToken.new(type: :http_scheme, value: matched_term)
        when 6
          tokens << QueryToken.new(type: :wildcard, value: matched_term)
        when 7
          tokens << QueryToken.new(type: :colon, value: matched_term)
        when 8
          tokens << QueryToken.new(type: :opening_bracket, value: matched_term)
        when 9
          tokens << QueryToken.new(type: :closing_bracket, value: matched_term)
        when 10
          tokens << QueryToken.new(type: :double_quote, value: matched_term)
        when 11
          tokens << QueryToken.new(type: :single_quote, value: matched_term)
        when 12
          tokens << QueryToken.new(type: :string, value: matched_term)
        else
          puts "Tokeniser was not able to assign a token to: #{matched_term}" if Rails.env.development? || Rails.env.test?
          next
        end
      end
    end

    tokens
  end
end