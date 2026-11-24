# frozen_string_literal: true

class QueryValidator

  attr_reader :tokens

  def initialize(tokens)
    @tokens = tokens
  end

  ##
  # Tokens are now a data class with a type (symbol, e.g. :boolean_operator) and a value (various data types)

  def validate
    validate_brackets(tokens)
  end

  private

  def validate_brackets(tokens)
    stack = []
    errors = []

    tokens.each do |token|
      case token.type
      when :open_bracket
        stack << token

      when :close_bracket
        if stack.empty?
          # error for unexpected closing bracket
          errors << QueryValidationError(token)
        else
          stack.pop
        end
      else
        next
      end
    end

    stack.each do |token|
      # error for missing closing bracket
      errors << QueryValidationError(token)
    end

    errors
  end
end
