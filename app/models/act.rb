class Act < ContentObject

  def initialize(content_object_data)
    super
  end

  def object_name
    subtype_or_type
  end

  def bill
    # returns the associated Bill object, if it exists

    bill_uris = get_all_from('isVersionOf_t')&.pluck(:value)
    return if bill_uris.blank?

    ObjectsFromUriList.new(bill_uris).get_objects[:items]&.first
  end

  def bill_link
    get_first_from('isVersionOf_t')
  end

  def isbn
    get_first_from('isbn_t')
  end

  def long_title
    get_first_from('longTitle_t')
  end
end