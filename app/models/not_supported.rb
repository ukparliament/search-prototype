class NotSupported < ContentTypeObject

  def initialize(content_type_object_data)
    super
  end

  def template
    'content_type_objects/object_pages/not_supported'
  end

  def search_result_partial
    'search/results/not_supported'
  end

end