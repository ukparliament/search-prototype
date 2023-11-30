class ParliamentaryProceeding < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/parliamentary_proceeding'
  end

  def object_name
    subtype_id = first_subtype
    subtype_id.blank? ? type : subtype_id
  end

  def first_subtype
    # TODO: temporary method - need to clear up what this should show & how
    # e.g. should this show last rather than first subtype?
    get_first_from('subtype_ses')
  end

  def location

  end

  def contributions

  end

  def answering_members
    get_all_from('answeringMember_ses')
  end

end