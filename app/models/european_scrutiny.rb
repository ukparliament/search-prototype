class EuropeanScrutiny < ContentObject

  def initialize(content_object_data)
    super
  end

  def associated_objects
    ids = super
    ids << regarding_object_ids
    ids.flatten.compact.uniq
  end

  def department
    fallback(get_first_from('department_ses'), get_first_from('department_t'))
  end

  def regarding_object_ids
    combine_fields(get_all_ids_from('regardingDD_uri'), get_all_ids_from('regardingDD_t'))
  end
end