class ParliamentaryPaper < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/parliamentary_paper'
  end

  def object_name
    'parliamentary paper'
  end
end