class TermCombiner

  attr_reader :terms

  def initialize(terms)
    @terms = terms
  end

  def combine_terms
    # basis of string is first search term
    # apply wrapping (parentheses) to first term if required
    if terms.size > 1 && wrapping_required?(terms.first)
      output_string = "(#{terms.first})"
    else
      output_string = "#{terms.first}"
    end

    # track current end of string as it determines what we do with the next term
    previous_term_is_operator = false

    terms.drop(1).each do |term|
      if %w[AND OR NOT].include?(term.upcase)
        # term is actually an operator, so just add it to the string without doing anything else to it
        # this outcome can stack, e.g. 'term AND NOT term'
        output_string += " #{term}"
        previous_term_is_operator = true
      else
        # term is a genuine term, not an operator
        if previous_term_is_operator
          # previous term was an operator already, so just append the term
          # add () if not already present
          output_string += wrapping_required?(term) ? " (#{term})" : " #{term}"
          previous_term_is_operator = false
        else
          # previous term was also a genuine term, not an operator, so append with AND
          # add () if not already present
          output_string += wrapping_required?(term) ? " AND (#{term})" : " AND #{term}"
          previous_term_is_operator = false
        end
      end
    end

    output_string
  end

  def wrapping_required?(str)
    # if it's just one word (no spaces) we don't need to wrap it, so just return false if that's the case
    return false unless str.include?(" ")

    # where already wrapped in brackets, we might need to wrap again - so starting and ending with them
    # doesn't mean it's not required

    # but in any case where it doesn't start & end with brackets we DO need to wrap it, so return true
    return true unless str.start_with?('(') && str.end_with?(')')

    # for strings that are already wrapped in brackets, we need to check whether we have an odd or even number
    # depth indicates how many sets of brackets we're within as we move through the string
    depth = 0

    # iterate through string checking for brackets & update depth count
    str.each_char.with_index do |char, i|
      depth += 1 if char == '('
      depth -= 1 if char == ')'

      # If there are internal brackets like "( ( ) ( ) )", we don't need to wrap. In this case, the depth will
      # remain >0 until the end.
      # So, we check for depth hitting zero at any point before the end of the string, and return true if this
      # happens.
      return true if depth == 0 && i < str.length - 1
    end

    # If we reach the end of the string and depth is 0, we've balanced all the brackets & they're all enclosed
    # as necessary, so we can return false
    if depth == 0
      false
    else
      true
    end
  end
end