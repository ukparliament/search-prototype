class ParliamentaryCommittee < ParliamentaryPaperReported

  def initialize(content_object_data)
    super
  end

  def search_result_partial
    'search/results/parliamentary_committee'
  end

  def search_result_ses_fields
    %w[type_ses subtype_ses corporateAuthor_ses
       legislationTitle_ses witness_ses subject_ses legislature_ses]
  end
end