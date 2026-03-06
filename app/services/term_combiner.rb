class TermCombiner
  
  attr_reader :terms
  
  def initialize(terms)
    @terms = terms
  end

  def combine
    # basis of string is first search term
    output_string = "#{terms.first}"

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
          # add parentheses around the term
          output_string += " #{term}"
          previous_term_is_operator = false
        else
          # previous term was also a genuine term, not an operator, so append with AND
          # add parentheses around the term
          output_string += " AND #{term}"
          previous_term_is_operator = false
        end
      end
    end

    output_string
  end

end