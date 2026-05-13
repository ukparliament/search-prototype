class Petition < ContentTypeObject

  def initialize(content_type_object_data)
    super
  end

  def object_name
    subtype_or_type
  end

  def template
    'content_type_objects/object_pages/petition'
  end

  def search_result_partial
    'search/results/petition'
  end

  def multi_member?
    members.size > 1
  end

  def members
    get_all_from('leadMember_ses')
  end

  def petition_text
    get_first_as_html_from('petitionText_t')
  end

  def content
    abstract_text.blank? ? petition_text : abstract_text
  end

  def self.search_result_solr_fields
    # fields requested in Solr search for search results page
    super << %w[
    title_t
    uri
    leadMember_ses
    subject_ses
    ]
  end

end