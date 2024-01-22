class EuropeanScrutiny < ContentObject

  def initialize(content_object_data)
    super
  end

  def regarding_link
    get_first_from('regardingDD_uri')
  end

  def regarding_title
    # When the regarding object has no title, we need to assemble one using its subtype or type
    # This requires a separate call to SES

    if regarding_object.page_title.blank?
      ses_data = SesLookup.new([regarding_object.object_name]).data
      ses_name = ses_data[regarding_object.object_name[:value]]
      "an untitled #{ses_name&.singularize}"
    else
      regarding_object.page_title
    end
  end

  def regarding_object
    return if regarding_link.blank?

    regarding_data = SolrQuery.new(object_uri: regarding_link[:value]).object_data
    ContentObject.generate(regarding_data)
  end
end