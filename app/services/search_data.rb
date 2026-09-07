class SearchData

  attr_reader :search, :hierarchy_builder

  FILTER_GROUP_NAMES = {
    type_sesrollup: 'Type',
    legislature_ses: 'House',
    session_s: 'Session',
    department_ses: 'Department',
    member_ses: 'Member',
    primaryMember_ses: 'Primary member',
    answeringMember_ses: 'Answering member',
    legislativeStage_ses: 'Legislative stage',
    legislationTitle_ses: 'Legislation',
    legislationTitle_s: 'Legislation',
    subject_ses: 'Subject',
    subject_s: 'Subject',
    publisher_ses: 'Publisher',
    date_year: 'Year',
    date_month: 'Month'
  }

  def initialize(search)
    # @search is a hash of search parameters and data
    @search = search
    @hierarchy_builder = initialise_hierarchy
  end

  def initialise_hierarchy
    HierarchyBuilder.new
  end

  def initial_query_data
    # The first search returns only a URI & type_ses (see field list of SolrSearch)
    return unless search

    search.dig(:data, 'response', 'docs')
  end

  def object_uris
    return nil if initial_query_data.blank?

    initial_query_data.pluck('uri').uniq
  end

  def empty_objects
    objects = []
    initial_query_data&.each do |object_data|
      objects << ContentTypeObject.generate(object_data)
    end

    objects.reject { |o| o.is_a?(NotSupported) }
  end

  def object_data
    return [] if object_uris.blank?

    # construct a string listing all Solr fields required for the objects being loaded on this results page
    solr_fields = []
    empty_objects.each do |object|
      solr_fields << object.class.search_result_solr_fields
    end
    solr_fields_string = solr_fields.flatten.uniq.join(' ')

    # perform a second Solr query, requesting the exact objects being loaded on this results page via their URIs
    # request only the fields we need using the solr_fields_string previously constructed
    unsorted_items = SolrQueryWrapper.new(object_uris: object_uris, solr_fields: solr_fields_string).get_objects.dig(:items)

    # build unsorted items into a uri-keyed hash
    unsorted_items_hash = {}
    unsorted_items.each do |unsorted_item|
      key = unsorted_item.object_uri.dig(:value)
      unsorted_items_hash[key] = unsorted_item
    end

    # ensure the returned objects are sorted in the order of the initial set of object_uris
    ret = []
    object_uris&.each do |sorted_uri|
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

  def query_as_submitted
    return unless search

    search.dig(:data, "responseHeader", "params", "q")
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

  def sort
    return unless search

    from_params = search.dig(:search_parameters, :sort_by)

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

    per_page = search.dig(:search_parameters, :results_per_page)
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

  def filter_count
    return 0 unless filter
    filter.to_h.values.flatten.count
  end

  ##
  # Returns an array of hashes constructed from Solr facet data:
  # { :field_name, facets: [ { :field_name, :ses_id, :count },... ]}
  def facets
    return [] unless search

    facet_field_data = search.dig(:data, 'facets')
    return [] if facet_field_data.blank?

    facet_field_data.slice(*ordered_facet_fields).map do |k, v|
      { field_name: k, facets: sort_facets(add_field_name_to_facet_hash(k, v['buckets'])) }
    end
  end

  def filter_groups
    filter_groups = {}

    facets.each do |filter_hash|
      # { :field_name (str), facets: [] }
      # get name string from lookup
      name = FILTER_GROUP_NAMES.dig(filter_hash[:field_name].to_sym)

      # check whether the return array already has a filter by this name
      if filter_groups.has_key?(name)
        # add the data to the existing array
        filter_groups[name] += filter_hash[:facets]
      else
        # add to the return array
        filter_groups[name] = filter_hash[:facets]
      end
    end

    filter_groups
  end

  def type_facets
    ret = {}
    facets.select { |facet| facet.dig(:field_name) == "type_sesrollup" }.first&.dig(:facets)&.each { |h| ret[h.dig("val")] = h.dig("count") }
    ret
  end

  private

  ##
  # Array of field name strings used to extract Solr returned facet data in the correct order for display
  def ordered_facet_fields
    %w[type_sesrollup legislature_ses date_year date_month session_s department_ses member_ses primaryMember_ses answeringMember_ses legislativeStage_ses legislationTitle_ses legislationTitle_s subject_ses subject_s publisher_ses]
  end

  ##
  # Accepts a field name string and an array of hashes
  # Returns a modified version of the array, where each hash has the field name added
  def add_field_name_to_facet_hash(field_name, array_of_facets)
    array_of_facets.map do |facet_hash|
      facet_hash['field_name'] = field_name
      facet_hash
    end
  end

  ##
  # Accepts an array of hashes, with each hash representing a facet
  # Sorts the array by descending count and returns it
  def sort_facets(facet_field)
    facet_field.sort_by { |h| h["count"] }.reverse
  end
end