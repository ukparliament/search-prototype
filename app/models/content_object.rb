class ContentObject

  attr_reader :content_object_data

  def initialize(content_object_data)
    @content_object_data = content_object_data
  end

  def self.generate(content_object_data)
    # takes object data as an argument and returns an instance of the correct object subclass

    type_id = content_object_data['type_ses']&.first
    subtype_id = content_object_data['subtype_ses']&.first

    content_object_class(type_id, subtype_id).classify.constantize.new(content_object_data)
  end

  def object_name
    type
  end

  def object_title
    # returns the title, falling back to name
    return page_title unless page_title.blank?

    "Untitled #{object_name_text}"
  end

  def object_name_text
    return if subtype_or_type.blank?

    object_ses_data = SesLookup.new([subtype_or_type]).data
    object_ses_data[subtype_or_type[:value].to_i]&.singularize
  end

  def page_title
    # keeping this simple for now
    content_object_data['title_t']
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

  def subtype_or_type
    fallback(subtype, type)
  end

  def subtypes_or_type
    fallback(subtypes, [type])
  end

  def type
    get_first_from('type_ses')
  end

  def ses_data
    SesLookup.new(ses_lookup_ids).data
  end

  def content
    get_first_as_html_from('content_t')
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
    get_first_from('primarySponsorParty_ses')
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

  def external_location_uri
    get_first_from('externalLocation_uri')
  end

  def external_location_text
    get_first_from('externalLocation_t')
  end

  def internal_location_uri
    get_first_from('internalLocation_uri')
  end

  def content_location_uri
    get_first_from('contentLocation_uri')
  end

  def isbn
    get_first_from('ISBN_t')
  end

  def display_link
    external_location_uri.blank? ? external_location_text : external_location_uri
  end

  def has_link?
    # based on discussions, we are only displaying one link
    !display_link.blank?
  end

  def notes
    get_first_from('searcherNote_t')
  end

  def related_items
    relation_uris = get_all_from('relation_t')&.pluck(:value)
    ObjectsFromUriList.new(relation_uris).get_objects
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

  def answering_member
    get_first_from('answeringMember_ses')
  end

  def asking_member
    get_first_from('askingMember_ses')
  end

  def asking_member_party
    get_first_from('askingMemberParty_ses')
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

  def publisher_string
    # this is looking at a string (rather than SES id) for publisher in order to pick the correct graphic
    # this feels quite fragile and should be given further thought

    get_first_from('publisherSnapshot_s')
  end

  def publisher_logo_partial
    # TODO: investigate CSS approach
    # TODO: validate publisher names against accepted list?

    return unless publisher_string

    "/search/logo_svgs/#{publisher_string[:value].parameterize}"
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

  def get_as_boolean_from(field_name)
    return unless ['true', 'false', true, false].include?(content_object_data[field_name])

    result = ['true', true].include?(content_object_data[field_name]) ? true : false
    { value: result, field_name: field_name }
  end

  def get_first_from(field_name)
    return if content_object_data[field_name].blank?

    { value: content_object_data[field_name].first, field_name: field_name }
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

  def self.content_object_class(type_id, subtype_id)
    case type_id
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
      case subtype_id
      when 479373
        'PaperPetition'
      when 347214
        'ObservationsOnPetitions'
      else
        'ContentObject'
      end
    when 347207
      'FormalProceeding'
    when 90587
      # 'CommandPaper'
      'ParliamentaryPaperLaid'


    # These are both types & subtypes: 91561, 91563 and 51288
      # For reported papers, the subtype should be ignored and type shown in the sentence etc.
      # Need clarification on how to route items which have these IDs as type
    when 91561
      # 'HouseOfCommonsPaper'
      'ParliamentaryPaperLaid'
    when 91563
      # 'HouseOfLordsPaper'
      'ParliamentaryPaperLaid'
    when 51288
      # 'UnprintedPaper'
      'ParliamentaryPaperLaid'
    when 352156
      'ParliamentaryPaperReported'

    when 352261
      # 'UnprintedCommandPaper'
      'ParliamentaryPaperLaid'
    when 92347
      'ParliamentaryPaperLaid'

    when 92277
      'OralQuestion'
    when 286676
      'OralAnswerToQuestion'
    when 356748
      'OralQuestionTimeIntervention'
    when 356750
      'ProceedingContribution'
    when 352161
      # Grand committee
      'ParliamentaryProceeding'
    when 352151
      # Committee
      'ParliamentaryProceeding'
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