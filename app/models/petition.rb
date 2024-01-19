class Petition < ContentObject

  def initialize(content_object_data)
    super
  end

  def object_name
    subtype_or_type
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

end