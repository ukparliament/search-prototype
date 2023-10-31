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

  def certified_category
    return if content_object_data['certifiedCategory_ses'].blank?

    content_object_data['certifiedCategory_ses']
  end
end