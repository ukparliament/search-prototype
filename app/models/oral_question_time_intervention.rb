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

  def template
    'search/objects/oral_question_time_intervention'
  end

end