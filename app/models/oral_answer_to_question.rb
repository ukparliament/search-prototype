class OralAnswerToQuestion < Question

  def initialize(content_object_data)
    super
  end

  def associated_objects
    ids = super
    ids << question_id
    ids.flatten.compact.uniq
  end

  def template
    'search/objects/oral_answer_to_question'
  end

  def search_result_partial
    'search/results/oral_answer_to_question'
  end

  def has_question?
    question_id.blank? ? false : true
  end

  def question_id
    get_first_id_from('answerFor_uri')
  end

  def question_url
    get_first_from('answerFor_uri')
  end
end