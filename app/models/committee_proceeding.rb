class CommitteeProceeding < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/committee_proceeding'
  end

  def object_name
    'committee proceeding'
  end

end