class ParliamentaryProceeding < Proceeding

  def initialize(content_type_object_data)
    super
  end

  def associated_objects
    ids = super
    ids << contribution_ids
    ids.flatten.compact.uniq
  end

  def template
    'content_type_objects/object_pages/parliamentary_proceeding'
  end

  def search_result_partial
    'search/results/parliamentary_proceeding'
  end

  def self.search_result_solr_fields
    # fields requested in Solr search for search results page
    super << %w[
    title_t uri
    abstract_t
    leadMember_ses
    answeringMember_ses
    department_ses department_t
    type_ses subtype_ses
    legislativeStage_ses
    procedural_ses
    legislationTitle_ses legislationTitle_t
    subject_ses subject_t
    searcherNote_t
    date_dt identifier_t place_ses legislature_ses
    ]
  end

  def object_name
    subtypes_or_type
  end

  def contribution_ids
    get_all_ids_from('childContribution_uri')
  end

  def answering_members
    get_all_from('answeringMember_ses')
  end
end