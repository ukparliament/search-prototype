class PaperPetition < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/paper_petition'
  end

  def object_name
    subtype_or_type
  end

  def multi_member?
    members.size > 1
  end

  def members
    get_all_from('member_ses')
  end

  def content
    abstract_text.blank? ? get_first_as_html_from('petitionText_t') : abstract_text
  end
end