class OralQuestionTimeIntervention < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/oral_question_time_intervention'
  end

  def contribution
    get_first_from('contributionText_t')
  end

end