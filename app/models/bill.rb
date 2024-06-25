class Bill < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/bill'
  end

  def search_result_partial
    'search/results/bill'
  end

  def object_name
    subtype_or_type
  end

  def associated_objects
    # A method that returns the IDs of objects that are associated with this one
    # These IDs will be collated and a single Solr query will retrieve their data
    # The data will be staged in an associated_object_data hash, keyed to the ID of the object
    # Any methods that previously queried Solr directly will now use the same ID(s) to retrieve data from said hash

    ids = super
    ids << previous_version_id
    ids.flatten.uniq
  end

  def date_of_order
    get_first_as_date_from('dateOfOrderToPrint_dt')
  end

  def previous_version_id
    get_first_from('isVersionOf_t')[:value]
  end

  def version_title
    if subtype[:value] == 92585
      title[:value]
    else
      reference.map { |r| r[:value] }.join(' ')
    end
  end

  def title
    get_as_string_from('title_t')
  end

  def location_uri
    get_first_from('location_uri')
  end

  def display_link
    # For everything else, where there is no externalLocation, no Link, internalLocation is not surfaced in new Search
    location_uri.blank? ? nil : location_uri
  end
end