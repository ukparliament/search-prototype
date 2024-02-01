class ParliamentaryPaperLaid < Paper

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/parliamentary_paper_laid'
  end

  def dual_type?
    # used to show both type and subtype with equal importance in related items partial
    type[:value] == 91561 && subtype[:value] == 91563
  end
end