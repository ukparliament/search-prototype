class Edm < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/edm'
  end

  def edm_number
    get_first_from('edmNumber_t')
  end

  def search_result_partial
    'search/results/early_day_motion'
  end

  def amendments
    # Title is the title of the motion itself, with 'Amendment N' on the front
    # Reference is taken from identifier_t, after removing the first item

    return if content_object_data['amendmentText_t'].blank?
    return if content_object_data['amendment_numberOfSignatures_s'].blank?
    return if content_object_data['amendment_primarySponsorPrinted_t'].blank?
    return if content_object_data['amendment_primarySponsorParty_ses'].blank?
    return if content_object_data['identifier_t'].blank?
    return if content_object_data['amendment_dateTabled_dt'].blank?

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
        text: { value: values[0], field_name: 'amendmentText_t' },
        number_of_signatures: { value: values[1], field_name: 'amendment_numberOfSignatures_s' },
        primary_sponsor: { value: values[2], field_name: 'amendment_primarySponsorPrinted_t' },
        primary_sponsor_party: { value: values[3], field_name: 'amendment_primarySponsorParty_ses' },
        reference: { value: values[4], field_name: 'identifier_t' },
        date_tabled: { value: values[5]&.to_date, field_name: 'amendment_dateTabled_dt' },
      }
    end

    result_hashes
  end

  def withdrawn?
    return false unless state && state[:value] == 'Withdrawn'

    true
  end

  def state
    # 'Open', 'Closed', 'Withdrawn', 'Suspended'
    get_first_from('edmStatus_t')
  end

  def other_sponsors
    get_all_from('sponsor_ses')
  end

  def number_of_signatures
    get_first_from('numberOfSignatures_t')
  end
end