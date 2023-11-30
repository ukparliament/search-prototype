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

  def corrected?
    # TODO: confirm this should be first
    get_as_boolean_from('correctedWmsMc_b')
  end
end