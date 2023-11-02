class ParliamentaryProceeding < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/parliamentary_proceeding'
  end

  def object_name
    subtype
  end

  def location

  end

  def answering_members
    return if content_object_data['answeringMember_ses'].blank?

    content_object_data['answeringMember_ses']
  end

end