class QueryStringProcessor

  attr_reader :query

  def initialize(query)
    @query = query
  end

  def sequential_combinations
    term_array = query.is_a?(Array) ? query : split_words(query)
    results = []

    term_array.each_index do |start_idx|
      (start_idx...term_array.length).each do |end_idx|
        results << term_array[start_idx..end_idx].join(" ")
      end
    end

    results.sort_by { |phrase| -phrase.split.length }
  end

  def normalise_quotes
    raise "#{query} is not a String" unless query.is_a? String

    query.tr("’‘", "'").tr("“”", '"')
  end

  private

  def split_words(query_string)
    raise "#{query_string} is not a String" unless query_string.is_a? String

    query_string.split(" ")
  end
end