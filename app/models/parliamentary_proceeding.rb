class ParliamentaryProceeding < Proceeding

  def initialize(content_type_object_data)
    super
  end

  def associated_objects
    ids = super
    ids << contribution_ids
    ids.flatten.compact.uniq
  end

  def self.search_result_solr_fields
    # fields requested in Solr search for search results page
    super << %w[
    abstract_t
    answeringMember_ses
    askedToReplyAuthor_ses
    date_dt
    department_ses
    department_t
    identifier_t
    leadMember_ses
    legislationTitle_ses
    legislationTitle_t
    legislativeStage_ses
    legislature_ses
    place_ses
    procedural_ses
    searcherNote_t
    subject_ses
    subject_t
    title_t
    uri
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