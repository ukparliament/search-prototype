# frozen_string_literal: true

##
# Tokeniser processes a query string into an array of labelled tokens.
class Tokeniser
  attr_reader :query

  def initialize(query)
    @query = query
  end

  ##
  # Terms operates on the provided query string, returning an array of separate string 'terms' for tokenisation:
  # - Returns nil if no query is provided
  # - Otherwise returns an array of terms matching the following formats:
  #   - Specified fields, e.g. field_name:term or field_name:'term' or field_name:"term" or
  #     field_name:"a phrase" or field_name:'a phrase'.
  #   - Quoted phrases without a specified field, e.g. "any phrase wrapped in quotes", or 'like this'.
  #   - Unquoted words
  def terms
    return if query.blank?
    query.to_s.scan(/(\w+:"(?:[^"]+)")|(\w+:'(?:[^']+)')|(\w+:\[(?:[^\]]+)\])|(\w+:\S+)|(\[(?:[^\]]+)\])|"([^"]+)"|'([^']+)'|(\S+)/).flat_map(&:compact)
  end

  ##
  # Tokenise operates on the terms array, returning an array of tokens. Categories are:
  # - Solr operators (AND, OR etc.)
  # - specified_field:'with a word or phrase in quotes' (either "" or '')
  # - specified_field:[with a word or phrase not to be expanded] (signified by square brackets)
  # - specified_field:term (single word with no quotes)
  # - quoted phrases ("" or '')
  # - phrases not to be expanded (signified by square brackets)
  # - unquoted words
  #
  # The final step groups any adjacent unquoted words in the array into phrases before being returned.
  def tokenise
    tokens = []

    terms.each do |term|
      if term.match(/^(?:AND|OR|NOT)$/)
        tokens << [:operator, term]
      elsif term.match?(/\A[a-z]+:\/\//)
        tokens << [:url, term]
      elsif term.match(/(\w+:"(?:[^"]+)")/)
        tokens << [:specified_field_with_quoted_phrase, term]
      elsif term.match(/(\w+:'(?:[^']+)')/)
        tokens << [:specified_field_with_quoted_phrase, term]
      elsif term.match(/(\w+:\[(?:[^\]]+)\])/)
        tokens << [:specified_field_no_expansion, term]
      elsif term.match(/(\w+:\S+)/)
        tokens << [:specified_field, term]
      elsif term.match(/"([^"]+)"/)
        tokens << [:quoted_phrase, term]
      elsif term.match(/'([^']+)'/)
        tokens << [:quoted_phrase, term]
      elsif term.match(/\[(?:[^\]]+)\]/)
        tokens << [:no_expansion, term]
      else
        tokens << [:unquoted_word, term]
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