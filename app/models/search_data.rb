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

  def expanded_types
    return unless search

    expanded_id_param = search.dig(:search_parameters, :expanded_types)

    ret = []

    unless expanded_id_param.blank?
      ret = expanded_id_param.split(',').compact_blank.uniq
    end

    ret
  end

  def toggled_facets
    return unless search

    toggled_facet_param = search.dig(:search_parameters, :toggled_facets)

    ret = []

    unless toggled_facet_param.blank?
      ret = toggled_facet_param.split(',').compact_blank.uniq
    end

    ret
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
    page_parameter = search.dig(:search_parameters, :page)
    page_parameter.blank? ? 1 : page_parameter.to_i
  end

  def combined_ses_ids
    return unless search

    ses_ids = object_data.pluck('all_ses').flatten

    return ses_ids if facet_ses_ids.blank?

    facet_ses_ids + ses_ids
  end

  def facet_ses_ids
    facet_data = search.dig(:data, 'facets')
    return if facet_data.blank?

    # original, where we received facet data in the form [90775, 285] instead of new format of {"val"=>90775, "count"=>285}
    # facet_data.select { |k, v| ["ses", "sesrollup"].include?(k.split("_").last) }.flat_map { |k, v| Hash[*v].keys.map(&:to_i) }

    facet_data.select { |k, v| ["ses", "sesrollup"].include?(k.split("_").last) }.flat_map { |k, v| v["buckets"].pluck("val") }
  end

  def content_type_rollup_ids
    search.dig(:data, "facets", "type_sesrollup", "buckets").pluck("val")
  end

  def ses_data
    unique_ses_ids = { value: combined_ses_ids.uniq.sort }
    SesLookup.new([unique_ses_ids]).data unless unique_ses_ids.blank?
  end

  def facets
    return [] unless search

    facet_field_data = search.dig(:data, 'facets')
    return [] if facet_field_data.blank?

    facet_field_data.except("count").map do |k, v|
      { field_name: k, facets: sort_facets(v['buckets']) }
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

  def type_facets
    ret = {}
    facets.select { |facet| facet.dig(:field_name) == "type_sesrollup" }.first&.dig(:facets)&.each { |h| ret[h.dig("val")] = h.dig("count") }
    ret
  end

  private

  def sort_facets(facet_field)
    # input is now an array of hashes of [{ "val" => 12345, "count" => 3 }, ...]
    # this is already correctly formatted, just needs sorting by count

    facet_field.sort_by { |id, count| count }.reverse
  end
end