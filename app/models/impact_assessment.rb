class ImpactAssessment < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/impact_assessment'
  end

  def object_name
    'impact assessment'
  end

  def corporate_author
    return if content_object_data['corporateAuthor_ses'].blank?

    content_object_data['corporateAuthor_ses'].first
  end

end