class WrittenCorrection < ContentTypeObject

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

  def self.search_result_solr_fields
    # fields requested in Solr search for search results page
    super << %w[
    correctionText_t
    date_dt
    department_ses
    department_t
    identifier_t
    leadMember_ses
    leadMemberParty_ses
    legislationTitle_ses
    legislationTitle_t
    legislature_ses
    memberParty_ses
    member_ses
    searcherNote_t
    subject_ses
    subject_t
    title_t
    uri
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

  def written_correction?
    true
  end

  def corrected_item_link
    fallback(get_first_from('correctedItem_uri'), get_first_from('correctedItem_t'))
  end

  def corrected_item_id
    fallback(get_first_id_from('correctedItem_uri'), get_first_id_from('correctedItem_t'))
  end
end