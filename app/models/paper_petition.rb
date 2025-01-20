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

  def self.search_result_solr_fields
    # fields requested in Solr search for search results page
    %w[
    title_t uri
    petitionText_t
    abstract_t
    leadMember_ses
    type_ses subtype_ses
    legislationTitle_ses legislationTitle_t
    subject_ses subject_t
    searcherNote_t
    date_dt identifier_t legislature_ses
    ]
  end

  def object_name
    subtype
  end

  def content
    abstract_text.blank? ? petition_text : abstract_text
  end
end