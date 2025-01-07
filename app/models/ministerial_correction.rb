class MinisterialCorrection < ContentObject

  # TODO: rename to written correction for clarity

  def initialize(content_object_data)
    super
  end

  def associated_objects
    ids = super
    ids << corrected_item_id
    ids.flatten.compact.uniq
  end

  def object_name
    subtype_or_type
  end

  def template
    'search/objects/ministerial_correction'
  end

  def search_result_partial
    'search/results/ministerial_correction'
  end

  def search_result_ses_fields
    %w[type_ses subtype_ses member_ses memberParty_ses department_ses
       legislationTitle_ses subject_ses legislature_ses]
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

  def corrected_item_id
    fallback(get_first_id_from('correctedItem_uri'), get_first_id_from('correctedItem_t'))
  end
end