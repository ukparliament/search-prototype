class ParliamentaryProceeding < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/parliamentary_proceeding'
  end

  def object_name
    last_subtype
  end

  def last_subtype
    # temporary method - need to clear up what this should show & how
    return if content_object_data['subtype_ses'].blank?

    content_object_data['subtype_ses'].last
  end

  def location

  end

  def contributions

  end

  def answering_members
    return if content_object_data['answeringMember_ses'].blank?

    content_object_data['answeringMember_ses']
  end

end