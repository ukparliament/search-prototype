class ProceedingContribution < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/proceeding_contribution'
  end

  def object_name
    
    { value: contribution_type[:value], field_name: 'contributionType_t' }
  end

  def proceeding_contribution_uri
    fallback(get_first_from('parentProceeding_t'), get_first_from('parentProceeding_uri'))
  end

  def parent_object
    return if proceeding_contribution_uri.blank?

    parent_proceeding_uri = proceeding_contribution_uri[:value]
    response = ObjectsFromUriList.new([parent_proceeding_uri]).get_objects
    response[:items]&.first
  end
end