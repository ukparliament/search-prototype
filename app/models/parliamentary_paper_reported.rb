class ParliamentaryPaperReported < Paper

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/parliamentary_paper_reported'
  end

  def object_name
    subtype_or_type
  end
end