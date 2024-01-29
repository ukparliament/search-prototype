class WrittenStatement < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/written_statement'
  end

  def attachment
    get_all_from('attachment_t')
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
end