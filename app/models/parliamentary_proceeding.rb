class ParliamentaryProceeding < Proceeding

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/parliamentary_proceeding'
  end

  def contributions
    contribution_uris = get_all_from('childContribution_uri')&.pluck(:value)
    ObjectsFromUriList.new(contribution_uris).get_objects
  end

  def answering_members
    get_all_from('answeringMember_ses')
  end
end