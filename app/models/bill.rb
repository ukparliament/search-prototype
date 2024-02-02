class Bill < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/bill'
  end

  def object_name
    subtype_or_type
  end

  def date_of_order
    get_first_as_date_from('dateOfOrderToPrint_dt')
  end

  def previous_version_link
    get_first_from('isVersionOf_t')
  end

  def previous_version
    previous = get_all_from('isVersionOf_t')&.pluck(:value)
    return if previous.blank?

    ObjectsFromUriList.new(previous).get_objects[:items]&.first
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