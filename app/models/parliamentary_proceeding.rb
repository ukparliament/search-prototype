class ParliamentaryProceeding < Proceeding

  def initialize(content_object_data)
    super
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

  def contributions
    contribution_uris = get_all_from('childContribution_uri')&.pluck(:value)
    return if contribution_uris.blank?

    contribution_objects = ObjectsFromUriList.new(contribution_uris).get_objects
    return if contribution_objects.blank?

    ret = {}
    ret[:contribution_data] = contribution_objects[:items].map do |o|
      {
        member: o.member,
        reference: o.reference,
        uri: o.object_uri,
        text: o.contribution_text
      }
    end
    ret[:contribution_ses_data] = contribution_objects[:ses_lookup]
    ret
  end

  def answering_members
    get_all_from('answeringMember_ses')
  end
end