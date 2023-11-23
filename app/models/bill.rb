class Bill < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/bill'
  end

  def object_name
    'bill'
  end

  def contains_explanatory_memo?
    get_first_as_boolean_from('containsEM_b')
  end
end