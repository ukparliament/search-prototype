class ImpactAssessment < Paper

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/impact_assessment'
  end

  def search_result_partial
    'search/results/impact_assessment'
  end

  def search_result_ses_fields
    %w[type_ses subtype_ses department_ses corporateAuthor_ses
       legislationTitle_ses subject_ses legislature_ses]
  end

  def paper_type
    get_all_from('subtype_ses')
  end
end