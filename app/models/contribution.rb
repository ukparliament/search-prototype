class Contribution < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/contribution'
  end

  def object_name
    "Contribution"
  end

end