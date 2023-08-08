class Edm < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/edm'
  end

  def other_supporters
    # requires a SES lookup to fetch names
    return if content_object_data['signedMember_ses'].blank?

    content_object_data['signedMember_ses']
  end

  def session
    return if content_object_data['session_t'].blank?

    content_object_data['session_t'].first
  end

  def reference
    return if content_object_data['identifier_t'].blank?

    content_object_data['identifier_t'].first
  end

  def motion_text
    return if content_object_data['motionText_t'].blank?

    content_object_data['motionText_t'].first
  end

  def primary_sponsor
    return if content_object_data['primarySponsorPrinted_s'].blank?

    content_object_data['primarySponsorPrinted_s'].first
  end

  def date_tabled
    return if content_object_data['dateTabled_dt'].blank?

    content_object_data['dateTabled_dt'].first.to_date
  end

  def bibliographic_citations
    return if content_object_data['bibliographicCitation_s'].blank?

    content_object_data['bibliographicCitation_s']
  end

  def subjects
    return if content_object_data['subject_sesrollup'].blank?

    content_object_data['subject_sesrollup']
  end

  def external_location_uri
    return if content_object_data['externalLocation_uri'].blank?

    content_object_data['externalLocation_uri'].first
  end
end