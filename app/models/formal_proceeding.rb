class FormalProceeding < Proceeding

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/formal_proceeding'
  end

  def search_result_partial
    'search/results/formal_proceeding'
  end

  def search_result_ses_fields
    %w[type_ses subtype_ses leadMember_ses department_ses legislativeStage_ses
      procedural_ses legislationTitle_ses subject_ses legislature_ses]
  end

end