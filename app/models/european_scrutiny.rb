class EuropeanScrutiny < ContentObject

  def initialize(content_object_data)
    super
  end

  def regarding_objects
    return if regarding_links.blank?

    relation_uris = regarding_links&.pluck(:value)
    ObjectsFromUriList.new(relation_uris).get_objects
  end

  def department
    fallback(get_first_from('department_ses'), get_first_from('department_t'))
  end

  private

  def regarding_links
    combine_fields(get_all_from('regardingDD_uri'), get_all_from('regardingDD_t'))
  end
end