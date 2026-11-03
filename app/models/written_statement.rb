class WrittenStatement < ContentTypeObject

  def initialize(content_type_object_data)
    super
  end

  def self.search_result_solr_fields
    # fields requested in Solr search for search results page
    super << %w[
    askedToReplyAuthor_ses
    correctedWmsMc_b
    date_dt
    department_ses
    department_t
    identifier_t
    legislationTitle_ses
    legislationTitle_t
    legislature_ses
    memberParty_ses
    member_ses
    searcherNote_t
    statementText_t
    subject_ses
    subject_t
    title_t
    uri
    ]
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