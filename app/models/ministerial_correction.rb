class MinisterialCorrection < ContentTypeObject
  # TODO: rename to written correction for clarity

  def initialize(content_type_object_data)
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
    'content_type_objects/object_pages/ministerial_correction'
  end

  def search_result_partial
    'search/results/ministerial_correction'
  end

  def self.search_result_solr_fields
    # fields requested in Solr search for search results page
    super << %w[
    title_t uri
    correctionText_t
    member_ses memberParty_ses
    department_ses department_t
    type_ses subtype_ses
    legislationTitle_ses legislationTitle_t
    subject_ses subject_t
    searcherNote_t
    date_dt identifier_t legislature_ses
    ]
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