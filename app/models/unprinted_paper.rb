class UnprintedPaper < ParliamentaryPaperLaid

  def initialize(content_object_data)
    super
  end

  def reference
    get_all_from('reference_t')
  end

  def search_result_partial
    'search/results/unprinted_paper'
  end

  def search_result_ses_fields
    %w[type_ses subtype_ses member_ses department_ses corporateAuthor_ses
       legislationTitle_ses subject_ses legislature_ses]
  end
end