class ProceedingContribution < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/proceeding_contribution'
  end

  def object_name
    # TODO: dynamic? examples in wireframes are business question
    # and speaker's ruling
    { value: contribution_type[:value].downcase, field_name: 'contributionType_t' }
  end

  def contribution_type
    get_first_from('contributionType_t')
  end

  def location
  end

  def proceeding
  end

  def proceeding_type
  end
end