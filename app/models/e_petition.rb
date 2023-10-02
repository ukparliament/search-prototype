class EPetition < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/e_petition'
  end

  def object_name
    "e-Petition"
  end

end