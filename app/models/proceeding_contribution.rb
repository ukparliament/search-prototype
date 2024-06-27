class ProceedingContribution < ContentObject

  def initialize(content_object_data)
    super
  end

  def associated_objects
    ids = super
    ids << proceeding_contribution_uri
    ids.compact.flatten.uniq
  end

  def template
    'search/objects/proceeding_contribution'
  end

  def search_result_partial
    'search/results/proceeding_contribution'
  end

  def object_name
    subtype_or_type
  end

  def proceeding_contribution_uri
    fallback(get_first_id_from('parentProceeding_t'), get_first_id_from('parentProceeding_uri'))
  end
end