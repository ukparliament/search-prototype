class PaperPetition < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/paper_petition'
  end

  def object_name
    'paper petition'
  end

  def member
    return if content_object_data['member_ses'].blank?

    content_object_data['member_ses'].first
  end

end