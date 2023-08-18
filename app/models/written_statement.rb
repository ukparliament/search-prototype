class WrittenStatement < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/written_statement'
  end

  def object_name
    "written statement"
  end
end