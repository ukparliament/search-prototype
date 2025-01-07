class PaperPetition < Petition

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/paper_petition'
  end

  def search_result_partial
    'search/results/paper_petition'
  end

  def search_result_ses_fields
    %w[type_ses subtype_ses leadMember_ses legislationTitle_ses subject_ses legislature_ses]
  end

  def object_name
    subtype
  end

  def content
    abstract_text.blank? ? petition_text : abstract_text
  end
end