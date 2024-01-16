class Bill < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/bill'
  end

  def title
    get_as_string_from('title_t')
  end
end