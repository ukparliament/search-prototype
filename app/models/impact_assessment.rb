class ImpactAssessment < Paper

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/impact_assessment'
  end

  def search_result_partial
    'search/results/impact_assessment'
  end

  def search_result_solr_fields
    # fields requested in Solr search for search results page
    %w[
    title_t uri
    department_ses department_t
    type_ses subtype_ses
    corporateAuthor_ses corporateAuthor_t
    legislationTitle_ses legislationTitle_t
    subject_ses subject_t
    searcherNote_t
    commonsLibraryLocation_t lordsLibraryLocation_t
    date_dt identifier_t legislature_ses
    ]
  end

  def paper_type
    get_all_from('subtype_ses')
  end
end