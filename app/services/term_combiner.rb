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

    puts "Term combiner, first term: #{terms.first}" if Rails.env.development? || Rails.env.test?

    # track current end of string as it determines what we do with the next term
    # start with these booleans as false unless the first term was an operator / bracket
    previous_term_is_operator = %w[AND OR NOT].include?(terms.first.upcase)
    previous_term_is_opening_bracket = %w[(].include?(terms.first.upcase)
    previous_term_is_closing_bracket = %w[)].include?(terms.first.upcase)

    terms.drop(1).each do |term|
      puts "Term combiner, processing term: #{term}" if Rails.env.development? || Rails.env.test?
      # iteration begins with the second term, but we need to check the previous term (via the boolean flags) in
      # order to know how to process & format this one

      if %w[AND OR NOT].include?(term)
        puts "Term is an operator" if Rails.env.development? || Rails.env.test?
        # term is actually an operator, so just add it to the string without doing anything else to it
        # this outcome can stack, e.g. 'term AND NOT term'

        if previous_term_is_opening_bracket
          # don't add a space if previous term was opening bracket
          output_string += "#{term}"
        else
          output_string += " #{term}"
        end

        # set flags to show this term was an operator
        previous_term_is_operator = true
        previous_term_is_opening_bracket = false
        previous_term_is_closing_bracket = false

      elsif %w[(].include?(term)
        puts "Term is an opening bracket" if Rails.env.development? || Rails.env.test?
        # term is actually a "(" bracket, so just add it to the string without doing anything else to it

        if previous_term_is_opening_bracket
          # don't add a space if previous term was opening bracket
          output_string += "#{term}"
        else
          output_string += " #{term}"
        end

        # set flags to show this term was an opening bracket
        previous_term_is_opening_bracket = true
        previous_term_is_operator = false
        previous_term_is_closing_bracket = false

      elsif %w[)].include?(term)
        puts "Term is a closing bracket" if Rails.env.development? || Rails.env.test?
        # term is actually a ")" bracket, so just add it to the string without doing anything else to it
        # we don't need to add a space before a closing bracket under any conditions
        output_string += "#{term}"

        # set flags to show this term was a closing bracket
        previous_term_is_closing_bracket = true
        previous_term_is_operator = false
        previous_term_is_opening_bracket = false

      else
        # term is a genuine term, not an operator or a bracket
        puts "Term is a genuine term..." if Rails.env.development? || Rails.env.test?

        if previous_term_is_operator
          puts "...but previous term was an operator" if Rails.env.development? || Rails.env.test?
          # previous term was an operator already, so just append the term
          # add () if not already present
          output_string += wrapping_required?(term) ? " (#{term})" : " #{term}"

          # If wrapping _is_ required, then the 'previous term' becomes a closing bracket?

        elsif previous_term_is_opening_bracket
          puts "...but previous term was an opening bracket" if Rails.env.development? || Rails.env.test?
          # previous term was a "(" bracket, so we append the term without spacing
          # we still need to check whether the term needs wrapping in its own brackets as this can be valid
          # for example: "((this OR that) AND (these OR those))"
          output_string += wrapping_required?(term) ? "(#{term})" : "#{term}"

        elsif previous_term_is_closing_bracket
          puts "...but previous term was closing bracket" if Rails.env.development? || Rails.env.test?

          # previous term was a ")" bracket, so we need to add a space when appending this term
          # we also need to add an "AND" here as those brackets will surround a term
          # still need to check whether the current term needs wrapping also
          output_string += wrapping_required?(term) ? " AND (#{term})" : " AND #{term}"

        else
          puts "...and previous term was also a genuine term" if Rails.env.development? || Rails.env.test?
          # previous term was also a genuine term, not an operator, so append with AND
          # add () if not already present
          output_string += wrapping_required?(term) ? " AND (#{term})" : " AND #{term}"
        end

        # update flags to show that this was a term
        previous_term_is_operator = false
        previous_term_is_opening_bracket = false
        previous_term_is_closing_bracket = false
      end
    end

    output_string
  end

  def wrapping_required?(str)
    # if it's just one word (no spaces) we don't need to wrap it, so just return false if that's the case
    return false unless str.include?(" ")

    # where already wrapped in brackets, we might need to wrap again - so starting and ending with them
    # doesn't mean it's not required

    # If quoted, there's no need to wrap in brackets
    # TODO: consider a refactor where we check for internal quotes & balance as necessary, as with brackets below
    return false if str.start_with?("\"") && str.end_with?("\"")

    # but in any case where it doesn't start & end with brackets or quotes we DO need to wrap it, so return true
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