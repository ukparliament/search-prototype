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

  def title
    get_as_string_from('title_t')
  end
end