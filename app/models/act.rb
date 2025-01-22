class Act < ContentTypeObject

  def initialize(content_type_object_data)
    super
  end

  def associated_objects
    ids = super
    ids << bill_id
    ids.compact.flatten.uniq
  end

  def object_name
    subtype_or_type
  end

  def bill_id
    get_first_id_from('isVersionOf_t')
  end

  def long_title
    get_first_from('longTitle_t')
  end
end