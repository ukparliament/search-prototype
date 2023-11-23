class ParliamentaryProceeding < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/parliamentary_proceeding'
  end

  def object_name
    subtype_id = last_subtype
    subtype_id.blank? ? type : subtype_id
  end

  def last_subtype
    # TODO: temporary method - need to clear up what this should show & how
    return if content_object_data['subtype_ses'].blank?

    content_object_data['subtype_ses'].last
  end

  def location

  end

  def contributions

  end

  def answering_members
    get_all_from('answeringMember_ses')
  end

end