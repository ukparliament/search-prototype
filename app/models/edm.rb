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

  def search_result_solr_fields
    # fields requested in Solr search for search results page
    %w[
    title_t uri
    motionText_t
    primarySponsor_ses primarySponsorParty_ses
    amendmentText_t amendment_numberOfSignatures_s amendment_primarySponsor_ses amendment_primarySponsorPrinted_t amendment_primarySponsorParty_ses identifier_t amendment_dateTabled_dt
    type_ses subtype_ses
    legislationTitle_ses legislationTitle_t
    subject_ses subject_t
    searcherNote_t
    date_dt identifier_t legislature_ses
    ]
  end

  def amendments
    # Title is the title of the motion itself, with 'Amendment N' on the front
    # Reference is taken from identifier_t, after removing the first item

    original_hash = {
      text: content_object_data['amendmentText_t'].blank? ? {} : { value: content_object_data['amendmentText_t'], field_name: 'amendmentText_t' },
      number_of_signatures: content_object_data['amendment_numberOfSignatures_s'].blank? ? {} : { value: content_object_data['amendment_numberOfSignatures_s'], field_name: 'amendment_numberOfSignatures_s' },
      primary_sponsor: content_object_data['amendment_primarySponsor_ses'].blank? ? {} : { value: content_object_data['amendment_primarySponsor_ses'], field_name: 'amendment_primarySponsor_ses' },
      primary_sponsor_text: content_object_data['amendment_primarySponsorPrinted_t'].blank? ? {} : { value: content_object_data['amendment_primarySponsorPrinted_t'], field_name: 'amendment_primarySponsorPrinted_t' },
      primary_sponsor_party: content_object_data['amendment_primarySponsorParty_ses'].blank? ? {} : { value: content_object_data['amendment_primarySponsorParty_ses'], field_name: 'amendment_primarySponsorParty_ses' },
      reference: content_object_data['identifier_t']&.drop(1).blank? ? {} : { value: content_object_data['identifier_t']&.drop(1), field_name: 'identifier_t' },
      date_tabled: content_object_data['amendment_dateTabled_dt'].blank? ? {} : { value: content_object_data['amendment_dateTabled_dt'], field_name: 'amendment_dateTabled_dt' }
    }

    return [] if original_hash.values.pluck(:value).compact.blank?

    number_of_amendments = original_hash.values.pluck(:value).compact.map(&:size).max
    keys = original_hash.keys
    result_hashes = []

    number_of_amendments.times do |iteration|
      ret = {}
      keys.each do |key|
        ret[key] = { value: original_hash.dig(key, :value).blank? ? nil : original_hash.dig(key, :value)[iteration], field_name: original_hash.dig(key, :field_name) }
      end
      ret[:index] = iteration
      result_hashes << ret
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