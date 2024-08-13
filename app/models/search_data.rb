class SearchData

  attr_reader :search, :hierarchy_builder

  def initialize(search)
    # @search is a hash of search parameters and data
    @search = search
    @hierarchy_builder = initialise_hierarchy
    @associated_object_query_response = get_associated_object_data
  end

  def initialise_hierarchy
    HierarchyBuilder.new
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

  def expanded_types_string
    return if expanded_types.blank?

    expanded_types.join(',')
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

  def get_associated_object_data
    AssociatedObjects.new(objects).data
  end

  def associated_object_data
    @associated_object_query_response&.dig(:object_data)
  end

  def associated_ses_ids
    ids = @associated_object_query_response&.dig(:ses_ids)
    return [] if ids.blank?

    ids
  end

  def combined_ses_ids
    return unless search

    ses_ids = object_data.pluck('all_ses').flatten
    facet_ses_ids + ses_ids + associated_ses_ids.pluck(:value)
  end

  def facet_ses_ids
    facet_data = search.dig(:data, 'facets')
    return [] if facet_data.blank?

    ids = facet_data.select { |k, v| ["ses", "sesrollup"].include?(k.split("_").last) }.flat_map { |k, v| v["buckets"].pluck("val") }
    return [] if ids.blank?

    ids
  end

  def hierarchy_data
    hierarchy_builder.hierarchy_data
  end

  def hierarchy_ses_data
    # The hierarchy builder has to make a seperate SES request to a different serivce in order to retrieve the
    # hierarchy. We assemble the type name lookup from that request, rather than adding the IDs to the main bundled
    # request.
    hierarchy_builder.formatted_ses_data
  end

  def content_type_rollup_ids
    search.dig(:data, "facets", "type_sesrollup", "buckets").pluck("val")
  end

  def ses_data
    # TODO: Using a master list of fields, it should be possible to reduce the number of SES IDs requested from
    # related items, e.g. don't fetch all_ses as the IDs we need will be in fields we know the names of which have
    # fewer IDs to resolve overall.

    unique_ses_ids = { value: combined_ses_ids.uniq.sort }
    returned_data = SesLookup.new([unique_ses_ids]).data unless unique_ses_ids.blank?
    return hierarchy_ses_data if returned_data.blank?

    hierarchy_ses_data.merge(returned_data)
  end

  def facets
    return [] unless search

    facet_field_data = search.dig(:data, 'facets')
    return [] if facet_field_data.blank?

    facet_field_data.except("count").map { |k, v| { field_name: k, facets: sort_facets(v['buckets']) } }
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

  def sort_facets(facet_field)
    facet_field.sort_by { |h| h["count"] }.reverse
  end
end