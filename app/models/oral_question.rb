class OralQuestion < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/oral_question'
  end

  def object_name
    "Oral question"
  end

end