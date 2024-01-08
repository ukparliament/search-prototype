class ParliamentaryProceeding < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/parliamentary_proceeding'
  end

  def object_name
    subtype_or_type
  end

  def contributions
    contribution_uris = get_all_from('childContribution_uri').pluck(:value)
    ObjectsFromUriList.new(contribution_uris).get_objects
  end

  def legislative_stage
    get_first_from('legislativeStage_ses')
  end

  def answering_members
    get_all_from('answeringMember_ses')
  end

  def witnesses
    get_all_from('witness_ses')
  end
end