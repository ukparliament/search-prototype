class OralQuestionTimeIntervention < ContentObject

  def initialize(content_object_data)
    super
  end

  def object_name
    subtype_or_type
  end

  def search_result_partial
    'search/results/oral_question_time_intervention'
  end

  def search_result_ses_fields
    %w[type_ses subtype_ses member_ses memberParty_ses procedural_ses
       legislationTitle_ses subject_ses place_ses legislature_ses]
  end

  def template
    'search/objects/oral_question_time_intervention'
  end

end