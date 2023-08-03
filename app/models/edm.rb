class Edm < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/edm'
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