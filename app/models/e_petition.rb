class EPetition < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/e_petition'
  end

  def number_of_signatures
    get_first_from('numberOfSignatures_t')
  end

  def closed?
    get_first_as_boolean_from('sigStatus_s')
  end

end