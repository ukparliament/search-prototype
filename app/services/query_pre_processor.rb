# frozen_string_literal: true

class QueryPreProcessor

  attr_reader :tokens

  def initialize(tokens)
    @tokens = tokens
  end

  def process
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
  def group_unquoted_words_as_phrases(tokens)
    # iterates through tokens and groups all :unquoted_word tokens as :unquoted_phrases
    # while respecting the structure of the query relative to other terms
    ret = []
    unquoted_words = []
    previous_modifier_operator = nil

    tokens.each do |token|
      if token.type == :unquoted_word
        if previous_modifier_operator
          # this word is modified by the operator, so consider it a separate phrase to any subsequent unquoted words
          ret << QueryToken.new(type: :modifier_operator, value: previous_modifier_operator)
          ret << QueryToken.new(type: :unquoted_phrase, value: value)
        else
          # this word may be part of a phrase
          unquoted_words << token.value
        end
        # reset previous operator tracker
        previous_modifier_operator = nil
      else
        if previous_modifier_operator
          # add a retained modifier operator before continuing
          ret << QueryToken.new(type: :modifier_operator, value: previous_modifier_operator)
          previous_modifier_operator = nil
        end

        # current token is not an unquoted word so merge all unquoted words in the buffer (if any) as a phrase
        ret << QueryToken.new(type: :unquoted_phrase, value: unquoted_words.join(" ")) unless unquoted_words.empty?
        unquoted_words = []

        # hold on to operators until the next iteration
        if token.type == :modifier_operator
          previous_modifier_operator = token.value
        else
          # no operation necessary on other token types
          ret << token
        end
      end
    end

    # If the final token was a modifier operator, we need to manually add it at the end as the loop won't
    ret << QueryToken.new(type: :modifier_operator, value: previous_modifier_operator) if previous_modifier_operator

    # finally, if there are any unquoted words left, combine them as a phrase
    ret << QueryToken.new(type: :unquoted_phrase, value: unquoted_words.join(" ")) unless unquoted_words.empty?

    ret
  end
end
