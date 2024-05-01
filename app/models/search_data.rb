class SearchData

  attr_reader :search

  def initialize(search)
    @search = search
  end

  def all_data
    search.all_data
  end

  def response
    all_data['response']
  end

  def data
    response['docs']
  end

  def metadata
    response.except('docs')
  end

  def number_of_results
    response['numFound']
  end

  def start
    response['start']
  end

  def end
    start + search.rows
  end

  def total_pages
    (number_of_results / search.rows) + 1 unless number_of_results.blank?
  end

  def combined_ses_ids
    ses_ids = data.pluck('all_ses').flatten
    facet_ses = all_data['facet_counts']['facet_fields'].select { |k, v| ["ses", "sesrollup"].include?(k.split("_").last) }.flat_map { |k, v| Hash[*v].keys.map(&:to_i) }
    facet_ses + ses_ids
  end

  def ses_data
    unique_ses_ids = { value: combined_ses_ids.uniq }
    SesLookup.new([unique_ses_ids]).data unless unique_ses_ids.blank?
  end

  def facet_data
    all_data['facet_counts']['facet_fields'].map do |facet_field|
      { field_name: facet_field.first, facets: sort_facets(facet_field) }
    end
  end

  def query_time
    time = all_data['responseHeader']['QTime']
    return if time.blank?

    time.to_f / 1000
  end

  private

  def sort_facets(facet_field)
    Hash[*facet_field.last].sort_by { |name, count| count }.reverse
  end
end