class WrittenStatement < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/written_statement'
  end

  def attachment
    get_all_from('attachmentTitle_t')
  end

  def procedure
    get_first_from('procedural_ses')
  end

  def notes
    get_first_from('notes_t')
  end

  def statement_date
    date
  end

  def statement_text
    get_first_as_html_from('statementText_t')
  end

  def is_corrected
    get_first_as_boolean_from('correctedWmsMc_b')
  end

  def corrected?
    corrected_boolean = get_first_as_boolean_from('correctedWmsMc_b')
    return false unless corrected_boolean && corrected_boolean[:value] == true

    true
  end
end