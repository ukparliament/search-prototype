class ParliamentaryPaperLaid < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/parliamentary_paper_laid'
  end

  def object_name
    'parliamentary paper'
  end
end