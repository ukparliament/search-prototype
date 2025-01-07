class CommitteeProceeding < ParliamentaryProceeding

  def initialize(content_object_data)
    super
  end

  def search_result_partial
    'search/results/committee_proceeding'
  end

  def search_result_ses_fields
    %w[type_ses subtype_ses leadMember_ses answeringMember_ses department_ses
      corporateAuthor_ses legislativeStage_ses procedural_ses legislationTitle_ses
      witness_ses subject_ses legislature_ses]
  end
end