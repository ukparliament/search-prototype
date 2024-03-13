class MinisterialCorrection < ContentObject

  def initialize(content_object_data)
    super
  end

  def object_name
    subtype_or_type
  end

  def template
    'search/objects/ministerial_correction'
  end

  def correction_text
    get_first_from('correctionText_t')
  end

  def correcting_member
    get_first_from('correctingMember_ses')
  end

  def correcting_member_party
    get_first_from('correctingMemberParty_ses')
  end

  def correction_date
    date
  end

  def ministerial_correction?
    true
  end

  def corrected_item_link
    fallback(get_first_from('correctedItem_uri'), get_first_from('correctedItem_t'))
  end

  def corrected_object
    return if corrected_item_link.blank?

    corrected_item_data = SolrQuery.new(object_uri: corrected_item_link[:value]).object_data
    ContentObject.generate(corrected_item_data)
  end
end