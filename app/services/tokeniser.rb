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
  # Bucket 2: Solr boolean operators
  # Bucket 3: Solr modifier operators
  # Bucket 4: Wildcards (*) for retrieval of all records
  # Bucket 5: http://.... or similar
  # Bucket 6: uri:http://... or similar
  # Bucket 7: field_name:"term"
  # Bucket 8: field_name:'term'
  # Bucket 9: field_name:[phrase in square brackets]
  # Bucket 10: field_name:*
  # Bucket 11: field_name:term
  # Bucket 12: [phrase in square brackets]
  # Bucket 13: "double-quoted phrase"
  # Bucket 14: 'single-quoted phrase'
  # Bucket 15: term
  TOKEN_REGEX = /([()])|(AND|OR)|(NOT|-|\+)|(\*:\*)|([a-z]+:\/\/\S+)|(uri:[a-z]+:\/\/\S+)|(\w+:"(?:[^"]+)")|(\w+:'(?:[^']+)')|(\w+:\[(?:[^\]]+)\])|(\w+:\*)|(\w+:\S+)|(\[(?:[^\]]+)\])|"([^"]+)"|'([^']+)'|([^\s()\[\]{}:"^~!]+)/

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
          tokens << [:boolean_operator, matched_term]
        when 2
          tokens << [:modifier_operator, matched_term]
        when 3
          tokens << [:all_records, matched_term]
        when 4
          tokens << [:url, matched_term]
        when 5
          tokens << [:uri_field, matched_term]
        when 6, 7
          tokens << [:specified_field_with_quoted_phrase, matched_term]
        when 8
          tokens << [:specified_field_no_expansion, matched_term]
        when 9
          tokens << [:specified_field_wildcard, matched_term]
        when 10
          tokens << [:specified_field, matched_term]
        when 11
          tokens << [:no_expansion, matched_term]
        when 12, 13
          tokens << [:quoted_phrase, matched_term]
        when 14
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
  #
  # Experimental: the grouping process now checks for a NOT, + or - (modifier operator token) prior to an unquoted
  # word and will not attempt to group the word with subsequent unquoted words if present. In practice this means:
  # British Airways -> SES looks for "British Airways"
  # -British Airways -> SES looks for British and Airways separately because this actually means "Airways, not British"
  # Note: if the final token is a modifier operator it will be skipped as there's no subsequent iteration to
  # process it. However this is acceptable as there's no valid query where a modifier would come last?
  def group_unquoted_words_as_phrases(tokens)
    # iterates through tokens and groups all :unquoted_word tokens as :unquoted_phrases
    # while respecting the structure of the query relative to other terms
    ret = []
    unquoted_words = []
    previous_modifier_operator = nil

    tokens.each do |label, value|
      if label == :unquoted_word
        if previous_modifier_operator
          # this word is modified by the operator, so consider it a separate phrase to any subsequent unquoted words
          ret << [:modifier_operator, previous_modifier_operator]
          ret << [:unquoted_phrase, value]
        else
          # this word may be part of a phrase
          unquoted_words << value
        end
        # reset previous operator tracker
        previous_modifier_operator = nil
      else
        if previous_modifier_operator
          # add a retained modifier operator before continuing
          ret << [:modifier_operator, previous_modifier_operator]
          previous_modifier_operator = nil
        end

        # current token is not an unquoted word so merge all unquoted words in the buffer (if any) as a phrase
        ret << [:unquoted_phrase, unquoted_words.join(" ")] unless unquoted_words.empty?
        unquoted_words = []

        # hold on to operators until the next iteration
        if label == :modifier_operator
          previous_modifier_operator = value
        else
          # no operation necessary on other token types
          ret << [label, value]
        end
      end
    end

    # finally, if there are any unquoted words left, combine them as a phrase
    ret << [:unquoted_phrase, unquoted_words.join(" ")] unless unquoted_words.empty?
    ret
  end
end