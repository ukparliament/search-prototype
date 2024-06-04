class SearchData

  attr_reader :search

  def initialize(search)
    # @search is a hash of search parameters and data
    @search = search
  end

  def solr_error?
    # boolean returns true if an error code was returned from Solr
    search[:data].has_key?('code')
  end

  def error_code
    return unless solr_error?

    search.dig(:data, 'code')
  end

  def error_message
    return unless solr_error?

    search.dig(:data, 'msg')
  end

  def error_query
    return unless solr_error?

    search.dig(:search_parameters, 'query')
  end

  def error_partial_path
    return unless solr_error?

    if [401, 404].include?(error_code)
      "layouts/shared/error/#{error_code}"
    else
      "layouts/shared/error/500"
    end
  end

  def object_data
    return unless search

    search.dig(:data, 'response', 'docs')
  end

  def objects
    return [] if object_data.blank?

    ret = []
    object_data.each { |object_data| ret << ContentObject.generate(object_data) }
    ret
  end

  def number_of_results
    return unless search

    search.dig(:data, 'response', 'numFound')
  end

  def query
    return unless search

    search.dig(:search_parameters, :query)
  end

  def sort
    return unless search

    search.dig(:search_parameters, 'sort_by')
  end

  def start
    return unless search

    search.dig(:data, 'response', 'start')
  end

  def end
    start + results_per_page
  end

  def results_per_page
    return unless search

    per_page = search.dig(:search_parameters, 'results_per_page')
    per_page.blank? ? 20 : per_page.to_i
  end

  def total_pages
    (number_of_results / results_per_page) + 1 unless number_of_results.blank?
  end

  def current_page
    search[:page].blank? ? 1 : search[:page].to_i
  end

  def combined_ses_ids
    return unless search

    ses_ids = object_data.pluck('all_ses').flatten
    facet_ses_ids + ses_ids
  end

  def facet_ses_ids
    search.dig(:data, 'facet_counts', 'facet_fields').select { |k, v| ["ses", "sesrollup"].include?(k.split("_").last) }.flat_map { |k, v| Hash[*v].keys.map(&:to_i) }
  end

  def content_type_rollup_ids
    arr = []
    type_data = search.dig(:data, 'facet_counts', 'facet_fields', 'type_sesrollup')
    subtype_data = search.dig(:data, 'facet_counts', 'facet_fields', 'subtype_sesrollup')
    arr << Hash[*type_data].keys.uniq
    arr << Hash[*subtype_data].keys.uniq
    arr.flatten.map(&:to_i)
  end

  def ses_data
    unique_ses_ids = { value: combined_ses_ids.uniq.sort }
    SesLookup.new([unique_ses_ids]).data unless unique_ses_ids.blank?
  end

  def facets
    return unless search

    results = search.dig(:data, 'facet_counts', 'facet_fields').map do |facet_field|
      { field_name: facet_field.first, facets: sort_facets(facet_field) }
    end
  end

  def query_time
    return unless search&.dig(:data, 'responseHeader', 'QTime')

    time = search&.dig(:data, 'responseHeader', 'QTime')
    return if time.blank?

    time.to_f / 1000
  end

  def filter
    search.dig(:search_parameters, :filter)
  end

  private

  def sort_facets(facet_field)
    Hash[*facet_field.last].sort_by { |name, count| count }.reverse
  end
end