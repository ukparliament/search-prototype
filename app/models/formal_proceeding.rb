class FormalProceeding < Proceeding

  def initialize(content_type_object_data)
    super
  end

  def template
    'content_type_objects/object_pages/formal_proceeding'
  end

  def search_result_partial
    'search/results/formal_proceeding'
  end

  def self.search_result_solr_fields
    # fields requested in Solr search for search results page
    super << %w[
    title_t uri
    abstract_t
    leadMember_ses
    department_ses department_t
    type_ses subtype_ses
    legislativeStage_ses
    procedural_ses
    legislationTitle_ses legislationTitle_t
    subject_ses subject_t
    searcherNote_t
    date_dt identifier_t legislature_ses
    ]
  end
end