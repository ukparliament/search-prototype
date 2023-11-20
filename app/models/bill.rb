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
    return if content_object_data['containsEM_b'].blank?

    return false unless content_object_data['containsEM_b'].first == 'true'

    true
  end
end