class OralAnswerToQuestion < Question

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/oral_answer_to_question'
  end

  def has_question?
    question_url.blank? ? false : true
  end

  def question_url
    get_first_from('answerFor_uri')
  end

  def question_object
    return unless has_question?

    question_data = SolrQuery.new(object_uri: question_url).object_data
    ContentObject.generate(question_data)
  end
end