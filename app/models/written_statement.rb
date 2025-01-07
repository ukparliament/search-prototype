class WrittenStatement < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/written_statement'
  end

  def search_result_partial
    'search/results/written_statement'
  end

  def search_result_ses_fields
    %w[type_ses subtype_ses member_ses memberParty_ses department_ses
       legislationTitle_ses subject_ses legislature_ses]
  end

  def attachment
    get_all_from('attachmentTitle_t')
  end

  def procedure
    # wrapped in an array to allow use of the same partial as get_all_from used on other items
    # [nil].blank? == false so use compact to produce [].blank? instead
    # this will then fail conditional check (in partial) in cases where there's no data, as intended
    [get_first_from('procedural_ses')].compact
  end

  def notes
    get_first_from('searcherNote_t')
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