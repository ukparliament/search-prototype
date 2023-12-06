class ParliamentaryProceeding < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/parliamentary_proceeding'
  end

  def object_name
    subtype_or_type
  end

  def location

  end

  def contributions

  end

  def answering_members
    get_all_from('answeringMember_ses')
  end

end