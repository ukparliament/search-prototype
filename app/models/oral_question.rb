class OralQuestion < Question

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/oral_question'
  end

  def object_name
    subtype_or_type
  end

  def answer_text
    answer_object.answer_text
  end

  def answer_object
    # TODO: Awaiting confirmation that this is the correct approach
    return unless answered?

    return if answer_item_link.blank?

    answer_item_data = SolrQuery.new(object_uri: answer_item_link[:value]).object_data
    ContentObject.generate(answer_item_data)
  end

  def answer_item_link
    get_first_from('answerFor_uri')
  end

  def prelim_partial
    return '/search/preliminary_sentences/oral_question_withdrawn' if withdrawn?

    return '/search/preliminary_sentences/oral_question_tabled' if tabled?

    return '/search/preliminary_sentences/oral_question_answered' if answered?

    nil
  end

end