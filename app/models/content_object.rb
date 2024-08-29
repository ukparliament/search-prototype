class ContentObject

  attr_reader :content_object_data

  def initialize(content_object_data)
    @content_object_data = content_object_data
  end

  def self.generate(content_object_data)
    # takes object data as an argument and returns an instance of the correct object subclass

    type_id = content_object_data['type_ses']&.first
    subtype_ids = content_object_data['subtype_ses']

    content_object_class(type_id, subtype_ids).classify.constantize.new(content_object_data)
  end

  def object_name
    type
  end

  def search_result_partial
    'search/results/content_object'
  end

  def page_title
    content_object_data['title_t']
  end

  def object_title
    # Returns either a string field or a SES ID
    # Titles are then formatted by formatted_page_title helper method

    return page_title unless page_title.blank?

    subtype_or_type
  end

  def associated_objects
    ids = []
    ids << related_item_ids
    ids.flatten.compact.uniq
  end

  def amendments
    nil
  end

  def get_associated_objects
    ObjectsFromUriList.new(associated_objects).get_objects
  end

  def ses_lookup_ids
    get_all_from('all_ses')
  end

  def subtype
    get_first_from('subtype_ses')
  end

  def subtypes
    get_all_from('subtype_ses')
  end

  def types
    get_all_from('type_ses')
  end

  def subtype_or_type
    fallback(subtype, type)
  end

  def subtypes_or_type
    return if subtypes.blank? && type.blank?

    fallback(subtypes, [type])
  end

  def type
    get_first_from('type_ses')
  end

  def content
    get_first_as_html_from('content_t')
  end

  def description
    get_first_as_html_from('description_t')
  end

  def abstract_text
    get_as_html_from('abstract_t')
  end

  def contains_explanatory_memo
    # bills, laid papers & SIs
    get_first_as_boolean_from('containsEM_b')
  end

  def contains_impact_assessment
    # laid papers & SIs
    get_first_as_boolean_from('containsIA_b')
  end

  def contribution_type
    # proceeding contributions & oral questions
    get_first_from('contributionType_t')
  end

  def published_on
    get_first_as_date_from('created_dt')
  end

  def reference
    combine_fields(get_all_from('identifier_t'), get_all_from('reference_t'))
  end

  def subjects
    from_ses = get_all_from('subject_ses')
    as_text = get_all_from('subject_t')

    combine_fields(from_ses, as_text)
  end

  def topics
    get_all_from('topic_ses')
  end

  def certified_categories
    get_all_from('certifiedCategory_ses')
  end

  def certified_date
    get_first_as_date_from('dateCertified_dt')
  end

  def date_tabled
    get_first_as_date_from('dateTabled_dt')
  end

  def legislation
    from_ses = get_all_from('legislationTitle_ses')
    as_text = get_all_from('legislationTitle_t')

    combine_fields(from_ses, as_text)
  end

  def department
    # 'asked to reply author' is a third party body that needs to be removed from department SES
    # this returns multiple data objects in an array
    # then filters out the atra ID (even if it's nil) & returns the first remaining item

    if asked_to_reply_author.blank?
      get_first_from('department_ses')
    else
      get_all_from('department_ses').reject { |h| h[:value] == asked_to_reply_author[:value] }.first
    end
  end

  def departments
    combine_fields(get_all_from('department_ses'), get_all_from('department_t'))
  end

  def asked_to_reply_author
    get_first_from('askedToReplyAuthor_ses')
  end

  def place
    get_first_from('place_ses')
  end

  def commons_library_location
    get_first_from('commonsLibraryLocation_t')
  end

  def lords_library_location
    get_first_from('lordsLibraryLocation_t')
  end

  def motion_text
    get_first_from('motionText_t')
  end

  def primary_sponsor
    get_first_from('primarySponsor_ses')
  end

  def primary_sponsor_party
    get_all_from('primarySponsorParty_ses')
  end

  def legislature
    get_all_from('legislature_ses')
  end

  def registered_interest_declared
    get_first_as_boolean_from('registeredInterest_b')
  end

  def object_uri
    get_as_string_from('uri')
  end

  def indexing_link
    base = 'http://indexing.parliament.uk/Content/Edit/1?uri='
    return if object_uri.blank?

    base + object_uri[:value]
  end

  def external_location_uri
    get_first_from('externalLocation_uri')
  end

  def internal_location_uri
    get_first_from('internalLocation_uri')
  end

  def timestamp
    get_as_date_from('timestamp')
  end

  def solr_deep_link
    return if object_uri.blank?

    "https://search.parliament.uk/claw/solr/?id=#{object_uri[:value]}"
  end

  def external_location_text
    get_first_from('externalLocation_t')
  end

  def content_location_uri
    get_first_from('contentLocation_uri')
  end

  def isbn
    get_first_from('ISBN_t')
  end

  def display_link
    fallback(external_location_uri, external_location_text)
  end

  def has_link?
    # based on discussions, we are only displaying one link
    !display_link.blank?
  end

  def notes
    get_first_from('searcherNote_t')
  end

  def related_item_ids
    get_all_ids_from('relation_t')
  end

  def contribution_text
    get_first_as_html_from('contributionText_t')
  end

  def contribution_short_text
    get_first_as_html_from('contributionText_s')
  end

  def parliamentary_session
    get_first_from('session_t')
  end

  def ec_documents
    get_first_from('eCDocument_t')
  end

  def procedure
    get_all_from('procedural_ses')
  end

  def procedure_scrutiny_period
    get_first_from('approvalDays_t')
  end

  def member
    get_first_from('member_ses')
  end

  def member_party
    get_first_from('memberParty_ses')
  end

  def member_parties
    get_all_from('memberParty_ses')
  end

  def answering_member
    get_first_from('answeringMember_ses')
  end

  def asking_member
    get_first_from('askingMember_ses')
  end

  def asking_member_party
    get_first_from('askingMemberParty_ses')
  end

  def asking_member_parties
    get_all_from('askingMemberParty_ses')
  end

  def lead_member
    get_first_from('leadMember_ses')
  end

  def lead_members
    get_all_from('leadMember_ses')
  end

  def lead_member_party
    get_first_from('leadMemberParty_ses')
  end

  def corporate_author
    combine_fields(get_all_from('corporateAuthor_ses'), get_all_from('corporateAuthor_t'))
  end

  def witnesses
    combine_fields(get_all_from('witness_ses'), get_all_from('witness_t'))
  end

  def contains_statistics
    # TODO: pass all three field names via filter

    contains_stats = get_first_as_boolean_from('containsStatistics_b')
    has_table = get_first_as_boolean_from('hasTable_b')
    stats_indicated = get_first_as_boolean_from('statisticsIndicated_b')

    return { value: true } if contains_stats && contains_stats[:value] == true

    return { value: true } if has_table && has_table[:value] == true

    return { value: true } if stats_indicated && stats_indicated[:value] == true

    { value: false }
  end

  def date
    # generic date field
    get_as_date_from('date_dt')
  end

  def dual_type?
    false
  end

  def ministerial_correction?
    false
  end

  def standard_house
    get_all_from('legislature_ses')
  end

  def standard_reference
    # this is always just identifier_t
    get_all_from('identifier_t')
  end

  def standard_date
    # this is always just date_dt
    get_as_date_from('date_dt')
  end

  private

  def get_as_string_from(field_name)
    return if content_object_data[field_name].blank?

    { value: content_object_data[field_name], field_name: field_name }
  end

  def get_first_as_boolean_from(field_name)
    return unless ['true', 'false', true, false].include?(content_object_data[field_name]&.first)

    result = ['true', true].include?(content_object_data[field_name].first) ? true : false
    { value: result, field_name: field_name }
  end

  def get_first_from(field_name)
    return if content_object_data[field_name].blank?

    { value: content_object_data[field_name].first, field_name: field_name }
  end

  def get_first_id_from(field_name)
    return if content_object_data[field_name].blank?

    content_object_data[field_name].first
  end

  def get_all_ids_from(field_name)
    return if content_object_data[field_name].blank?

    content_object_data[field_name]
  end

  def get_first_as_html_from(field_name)
    return if content_object_data[field_name].blank?

    { value: CGI::unescapeHTML(content_object_data[field_name].first), field_name: field_name }
  end

  def get_as_html_from(field_name)
    return if content_object_data[field_name].blank?

    { value: CGI::unescapeHTML(content_object_data[field_name]), field_name: field_name }
  end

  def get_first_as_date_from(field_name)
    # some dates are single strings stored in arrays
    return if content_object_data[field_name].blank?

    valid_date_string = validate_datetime(content_object_data[field_name].first)
    return unless valid_date_string

    { value: valid_date_string, field_name: field_name }
  end

  def get_as_date_from(field_name)
    # some dates are stored as strings
    return if content_object_data[field_name].blank?

    valid_date_string = validate_datetime(content_object_data[field_name])
    return unless valid_date_string

    { value: valid_date_string, field_name: field_name }
  end

  def get_all_from(field_name)
    # returns an array of hashes that follow the standard structure
    # when / if refactored this will be an array of data structure objects
    # this is done so a view can iterate across the result of get_all_from (e.g. legislation)
    # and build links for each item using the same helper methods as used for a single data object
    return if content_object_data[field_name].blank?

    content_object_data[field_name].map { |value| { value: value, field_name: field_name } }
  end

  def self.content_object_class(type_id, subtype_ids)
    case type_id
    when 363376
      'ResearchMaterial'
    when 90996
      'Edm'
    when 346697
      'ResearchBriefing'
    when 93522
      'WrittenQuestion'
    when 352211
      'WrittenStatement'
    when 347125
      'ChurchOfEnglandMeasure'
    when 352234
      'PrivateAct'
    when 347135
      'PublicAct'
    when 92034
      'MinisterialCorrection'
    when 91613
      'ImpactAssessment'
    when 347163
      'DepositedPaper'
    when 360977
      'TransportAndWorksActOrderApplication'
    when 347122
      'Bill'
    when 92435
      if subtype_ids&.include?(479373)
        'PaperPetition'
      elsif subtype_ids&.include?(347214)
        'ObservationsOnPetitions'
      else
        'ContentObject'
      end
    when 347207
      'FormalProceeding'
    when 90587
      # CommandPaper inherits from ParliamentaryPaperLaid
      'CommandPaper'
    when 91561
      # HouseOfCommons paper inherits from ParliamentaryPaperLaid
      'HouseOfCommonsPaper'
    when 91563
      # 'HouseOfLordsPaper'
      'ParliamentaryPaperLaid'
    when 51288
      # UnprintedPaper inherits from ParliamentaryPaperLaid
      'UnprintedPaper'
    when 352156
      # ParliamentaryCommittee inherits from ParliamentaryPaperReported
      'ParliamentaryCommittee'
    when 352261
      # UnprintedCommandPaper inherits from ParliamentaryPaperLaid
      'UnprintedCommandPaper'
    when 92347
      if subtype_ids&.include?(528119)
        'PaperOrderedToBePrinted'
      elsif subtype_ids&.include?(528127)
        'PaperOrderedToBePrinted'
      elsif subtype_ids&.include?(528129)
        'PaperSubmitted'
      elsif subtype_ids&.include?(51288)
        # changed from ParliamentaryPaperLaid when object added
        'UnprintedPaper'
      else
        'ParliamentaryPaperLaid'
      end
    when 92277
      'OralQuestion'
    when 286676
      'OralAnswerToQuestion'
    when 356748
      'OralQuestionTimeIntervention'
    when 356750
      'ProceedingContribution'
    when 352161
      # Grand committee proceeding inherits from parliamentary proceeding
      'GrandCommitteeProceeding'
    when 352151
      # Committee proceeding inherits from parliamentary proceeding
      'CommitteeProceeding'
    when 352179
      'ParliamentaryProceeding'
    when 347226
      'StatutoryInstrument'
    when 347028
      'EuropeanDepositedDocument'
    when 347036
      'EuropeanScrutinyExplanatoryMemorandum'
    when 347040
      'EuropeanScrutinyMinisterialCorrespondence'
    when 347032
      'EuropeanScrutinyRecommendation'
    when 347010
      'EuropeanMaterial'
    else
      'ContentObject'
    end
  end

  def validate_datetime(date)
    # All dates are stored as datetimes in the UK timezone

    begin
      date_string = DateTime.parse(date).in_time_zone('London')
    rescue Date::Error
      return nil
    end

    date_string
  end

  def combine_fields(first, second)
    return nil if first.blank? && second.blank?

    return first if second.blank?

    return second if first.blank?

    first + second
  end

  def fallback(preferred, alternative)
    preferred.blank? ? alternative : preferred
  end

end