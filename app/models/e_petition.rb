class EPetition < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/e_petition'
  end

  def object_name
    'e-petition'
  end

  def number_of_signatures
    return if content_object_data['numberOfSignatures_t'].blank?

    content_object_data['numberOfSignatures_t'].first
  end

  def closed?
    return if content_object_data['sigStatus_s'].blank?

    return false unless content_object_data['sigStatus_s'].first == 'closed'

    true
  end

end