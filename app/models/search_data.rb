class SearchData

  attr_reader :search, :hierarchy_builder

  def initialize(search)
    # @search is a hash of search parameters and data
    @search = search
    @hierarchy_builder = initialise_hierarchy
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

  def initial_query_data
    # The first search returns only a URI & type_ses (see field list of SolrSearch)
    return unless search

    search.dig(:data, 'response', 'docs')&.reject { |h| h.dig('type_ses').blank? }
  end

  def object_uris
    return nil if initial_query_data.blank?

    initial_query_data.pluck('uri').uniq
  end

  def empty_objects
    objects = []
    initial_query_data&.each do |object_data|
      next if object_data['type_ses'].blank?

      objects << ContentTypeObject.generate(object_data)
    end
    objects
  end

  def object_data
    return [] if object_uris.blank?

    solr_fields = []
    empty_objects.each do |object|
      solr_fields << object.class.search_result_solr_fields
    end

    solr_fields_string = solr_fields.flatten.uniq.join(' ')

    unsorted_items = SolrQueryWrapper.new(object_uris: object_uris, solr_fields: solr_fields_string).get_objects.dig(:items)

    # build unsorted items into a uri-keyed hash
    unsorted_items_hash = {}
    unsorted_items.each do |unsorted_item|
      key = unsorted_item.object_uri.dig(:value)
      unsorted_items_hash[key] = unsorted_item
    end

    # iterate through sorted uris and grab object from hash into array to return
    ret = []
    initial_query_data.pluck('uri').each do |sorted_uri|
      ret << unsorted_items_hash.dig(sorted_uri)
    end

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

  def show_detailed
    return unless search

    search.dig(:search_parameters, :show_detailed)
  end

  def show_detailed?
    show_detailed == "true" ? true : false
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

    from_params = search.dig(:search_parameters, 'sort_by')

    from_params.blank? ? 'date_desc' : from_params
  end

  def start
    return unless search

    solr_value = search.dig(:data, 'response', 'start')

    # start is zero-indexed in solr and our interactions with it, so + 1 for display
    solr_value + 1
  end

  def end
    return unless search

    # start + results per page would be the start of the following page
    # so subtract 1 to get the end of the current page
    start + results_per_page - 1
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

  def facet_ses_ids
    facet_data = search.dig(:data, 'facets')
    return [] if facet_data.blank?

    ids = facet_data.select { |k, v| ["ses", "sesrollup"].include?(k.split("_").last) }.flat_map { |k, v| v["buckets"].pluck("val") }
    return [] if ids.blank?

    ids
  end

  def years
    year_buckets = search&.dig(:data, "facets", "year", "buckets")
    return [] if year_buckets.blank?

    year_buckets.sort_by { |h| h["val"] }.uniq.reverse
  end

  def months(year_string)
    month_buckets = search&.dig(:data, "facets", "month", "buckets")
    return [] if month_buckets.blank?

    month_buckets.select { |m| m['val'].first(4) == year_string }.sort_by { |h| h["val"] }.uniq
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

  def query_time
    return unless search&.dig(:data, 'responseHeader', 'QTime')

    time = search&.dig(:data, 'responseHeader', 'QTime')
    return if time.blank?

    time.to_f / 1000
  end

  def filter
    search.dig(:search_parameters, :filter)
  end

  def facets
    return [] unless search

    facet_field_data = search.dig(:data, 'facets')
    return [] if facet_field_data.blank?

    facet_field_data.slice(*ordered_facet_fields).map { |k, v| { field_name: k, facets: sort_facets(v['buckets']) } }
  end

  def type_facets
    ret = {}
    facets.select { |facet| facet.dig(:field_name) == "type_sesrollup" }.first&.dig(:facets)&.each { |h| ret[h.dig("val")] = h.dig("count") }
    ret
  end

  def ordered_facet_fields
    # used to extract Solr returned facet data in the correct order for display
    %w[type_sesrollup legislature_ses session_t date_dt department_ses member_ses primaryMember_ses answeringMember_ses legislativeStage_ses legislationTitle_ses subject_ses publisher_ses]
  end

  def sort_facets(facet_field)
    facet_field.sort_by { |h| h["count"] }.reverse
  end

  def single_data_year?
    data_years.size == 1
  end

  def data_years
    return [] unless search

    date_facet = search.dig(:data, 'facets', 'date_dt')

    return [] if date_facet.blank?

    date_facet.dig("buckets").map { |b| b.dig("val").to_date.strftime("%Y") }.uniq
  end
end