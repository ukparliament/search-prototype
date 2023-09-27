class ParliamentaryPaperReported < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/parliamentary_paper_reported'
  end

  def object_name
    "Parliamentary paper - reported"
  end

end