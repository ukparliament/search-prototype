class Edm < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/edm'
  end

  def object_name
    'early day motion'
  end

  def amendments
    # amendments fields do not include duplicates, which means the data can not be reliably used
    # to avoid misrepresentation, we will not show amendments where there are more than one
    # this can be changed when the underlying data issue is resolved

    # Title is the title of the motion itself, with 'Amendment N' on the front
    # Reference is taken from identifier_t, after removing the first item

    return if content_object_data['amendmentText_t'].blank?
    return if content_object_data['amendment_numberOfSignatures_s'].blank?
    return if content_object_data['amendment_primarySponsorPrinted_t'].blank?
    return if content_object_data['amendment_primarySponsorParty_ses'].blank?
    return if content_object_data['identifier_t'].blank?
    return if content_object_data['amendment_dateTabled_dt'].blank?

    return if content_object_data['amendmentText_t'].size > 1

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

  def amendments_count
    return if amendments.blank?

    amendments.size
  end

  def withdrawn?
    return false unless state == 'Withdrawn'

    true
  end

  def open?
    return false unless state == 'Open'

    true
  end

  def closed?
    return false unless state == 'Closed'

    true
  end

  def suspended?
    return false unless state == 'Suspended'

    true
  end

  def subtype
    # the majority of EDMs have no subtype
    return if content_object_data['subtype_ses'].blank?

    content_object_data['subtype_ses'].first
  end

  def fatal_prayer?
    return false unless subtype == 445873

    true
  end

  def non_fatal_prayer?
    return false unless subtype == 445875

    true
  end

  def has_subtype?
    return false if subtype.blank?

    true
  end

  def subtype_name
    return 'fatal prayer' if fatal_prayer?

    return 'non-fatal prayer' if non_fatal_prayer?

    nil
  end

  def state
    # 'Open', 'Closed', 'Withdrawn', 'Suspended'
    return if content_object_data['edmStatus_t'].blank?

    content_object_data['edmStatus_t']
  end

  def amendment_text
    return if content_object_data['amendmentText_t'].blank?

    content_object_data['amendmentText_t']
  end

  def other_supporters
    # This is all other supporters and includes other sponsors
    return if content_object_data['signedMember_ses'].blank?

    content_object_data['signedMember_ses']
  end

  def other_sponsors
    # this is for the prelim sentence
    return if content_object_data['sponsor_ses'].blank?

    content_object_data['sponsor_ses']
  end

  def number_of_signatures
    return if content_object_data['numberOfSignatures_t'].blank?

    content_object_data['numberOfSignatures_t'].first
  end

  def motion_text
    return if content_object_data['motionText_t'].blank?

    content_object_data['motionText_t'].first
  end

  def primary_sponsor
    return if content_object_data['primarySponsor_ses'].blank?

    content_object_data['primarySponsor_ses'].first
  end

  def primary_sponsor_party
    return if content_object_data['primarySponsorParty_ses'].blank?

    content_object_data['primarySponsorParty_ses'].first
  end

  def date_tabled
    return if content_object_data['dateTabled_dt'].blank?

    content_object_data['dateTabled_dt'].first.to_date
  end

  def bibliographic_citations
    return if content_object_data['bibliographicCitation_s'].blank?

    content_object_data['bibliographicCitation_s']
  end

  def external_location_uri
    return if content_object_data['externalLocation_uri'].blank?

    content_object_data['externalLocation_uri'].first
  end
end