class NotSupported < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/not_supported'
  end

  def search_result_partial
    'search/results/not_supported'
  end

end