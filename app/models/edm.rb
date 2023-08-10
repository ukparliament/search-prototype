class Edm < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/edm'
  end

  def amendments
    # number of signatures won't necessarily match - need to confirm how to handle missing data
    # initial suggestion is that where missing, use the previous one (as that seems to be why they're missing)

    # Title is the title of the motion itself, with 'Amendment N' on the front
    # Reference is taken from identifier_t, after removing the first item

    # TODO: genericise this approach

    original_hash = {
      text: content_object_data['amendmentText_t'],
      number_of_signatures: content_object_data['amendment_numberOfSignatures_s'],
      primary_sponsor: content_object_data['amendment_primarySponsorPrinted_t'],
      primary_sponsor_party: content_object_data['amendment_primarySponsorParty_ses'],
      reference: content_object_data['identifier_t'].drop(1),
      date_tabled: content_object_data['amendment_dateTabled_dt'],
    }

    result_hashes = original_hash[:text].zip(
      original_hash[:number_of_signatures],
      original_hash[:primary_sponsor],
      original_hash[:primary_sponsor_party],
      original_hash[:reference],
      original_hash[:date_tabled],
    ).map.with_index do |values, index|
      {
        index: index,
        text: values[0],
        number_of_signatures: values[1],
        primary_sponsor: values[2],
        primary_sponsor_party: values[3],
        reference: values[4],
        date_tabled: values[5],
      }
    end

    result_hashes
  end

  def amendment_text
    return if content_object_data['amendmentText_t'].blank?

    content_object_data['amendmentText_t']
  end

  def other_supporters
    # requires a SES lookup to fetch names
    return if content_object_data['signedMember_ses'].blank?

    content_object_data['signedMember_ses']
  end

  def registered_interest_declared
    return if content_object_data['registeredInterest_b'].blank?

    content_object_data['registeredInterest_b'].first ? 'Yes' : 'No'
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