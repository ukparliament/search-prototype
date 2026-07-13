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
  # Bucket 1: Brackets
  # Bucket 2: Solr operators
  # Bucket 3: http://.... or similar
  # Bucket 4: uri:http://... or similar
  # Bucket 5: field_name:"term"
  # Bucket 6: field_name:'term'
  # Bucket 7: field_name:[phrase in square brackets]
  # Bucket 8: field_name:*
  # Bucket 9: field_name:term
  # Bucket 10: [phrase in square brackets]
  # Bucket 11: "double-quoted phrase"
  # Bucket 12: 'single-quoted phrase'
  # Bucket 13: term
  TOKEN_REGEX = /([()])|(\bAND|OR|NOT\b)|(\*:\*)|([a-z]+:\/\/\S+)|(uri:[a-z]+:\/\/\S+)|(\w+:"(?:[^"]+)")|(\w+:'(?:[^']+)')|(\w+:\[(?:[^\]]+)\])|(\w+:\*)|(\w+:\S+)|(\[(?:[^\]]+)\])|"([^"]+)"|'([^']+)'|([^\s()\[\]{}:"^~!]+)/

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
          tokens << [:parenthesis, matched_term]
        when 1
          tokens << [:operator, matched_term]
        when 2
          tokens << [:all_records, matched_term]
        when 3
          tokens << [:url, matched_term]
        when 4
          tokens << [:uri_field, matched_term]
        when 5, 6
          tokens << [:specified_field_with_quoted_phrase, matched_term]
        when 7
          tokens << [:specified_field_no_expansion, matched_term]
        when 8
          tokens << [:specified_field_wildcard, matched_term]
        when 9
          tokens << [:specified_field, matched_term]
        when 10
          tokens << [:no_expansion, matched_term]
        when 11, 12
          tokens << [:quoted_phrase, matched_term]
        when 13
          tokens << [:unquoted_word, matched_term]
        else
          puts "Term not matched by tokeniser: #{matched_term}" if Rails.env.development? || Rails.env.test?
          next
        end
      end
    end

    group_unquoted_words_as_phrases(tokens)
  end

  private

  ##
  # Groups adjacent unquoted words into phrases. This is to allow the terms to be sent to SES for term expansion as
  # a phrase, so that multi-word concepts are detected, but avoids combining words that weren't adjacent in the user's
  # query, which can lead to overexpansion.
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