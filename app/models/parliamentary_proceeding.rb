class ParliamentaryProceeding < Proceeding

  def initialize(content_object_data)
    super
  end

  def associated_objects
    ids = super
    ids << contribution_ids
    ids.flatten.compact.uniq
  end

  def template
    'search/objects/parliamentary_proceeding'
  end

  def search_result_partial
    'search/results/parliamentary_proceeding'
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