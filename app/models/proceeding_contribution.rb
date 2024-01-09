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
    [get_first_from('parentProceeding_t')[:value]]
  end

  def parent_object
    response = ObjectsFromUriList.new(proceeding_contribution_uri).get_objects
    response[:items]&.first
  end
end