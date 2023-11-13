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

  def ses_lookup_ids
    return if content_object_data['all_ses'].blank?

    content_object_data['all_ses']
  end

  def subtype
    return if content_object_data['subtype_ses'].blank?

    content_object_data['subtype_ses'].first
  end

  def type
    return if content_object_data['type_ses'].blank?

    content_object_data['type_ses'].first
  end

  def page_title
    content_object_data['title_t']
  end

  def ses_data
    SesLookup.new(ses_lookup_ids).data
  end

  def html_summary
    return if content_object_data['htmlsummary_t'].blank?

    CGI::unescapeHTML(content_object_data['htmlsummary_t'].first)
  end

  def content
    return if content_object_data['content_t'].blank?

    CGI::unescapeHTML(content_object_data['content_t'].first)
  end

  def abstract_text
    return if content_object_data['abstract_t'].blank?

    CGI::unescapeHTML(content_object_data['abstract_t'])
  end

  def published?
    return if content_object_data['published_b'].blank?

    return false unless content_object_data['published_b'].first == 'true'

    true
  end

  def published_on
    return if content_object_data['created_dt'].blank?

    valid_date_string = validate_date(content_object_data['created_dt'].first)
    return unless valid_date_string

    valid_date_string.to_date
  end

  def reference
    # typically used for Hansard col refs
    return if content_object_data['identifier_t'].blank?

    content_object_data['identifier_t'].first
  end

  def subjects
    # TODO: may sometimes also be subject_t instead of subject_ses, need to handle this
    return if content_object_data['subject_ses'].blank?

    content_object_data['subject_ses']
  end

  def topics
    # note - have not yet verified key as missing from test data
    return if content_object_data['topic_ses'].blank?

    content_object_data['topic_ses']
  end

  def certified_category
    return if content_object_data['certifiedCategory_ses'].blank?

    content_object_data['certifiedCategory_ses']
  end

  def legislation
    # TODO: sometimes leigislation text will be all that is present & we need to handle this
    # by displaying it instead of a labelled link

    return if content_object_data['legislationTitle_ses'].blank?

    content_object_data['legislationTitle_ses']
  end

  def department
    return if content_object_data['department_ses'].blank?

    content_object_data['department_ses'].first
  end

  def place
    return if content_object_data['place_ses'].blank?

    content_object_data['place_ses'].first
  end

  def library_location
    # this is for the commons library, but there's also lordsLibraryLocation_t
    # assume there's some logic needed for how to combine or conditionally present these
    return if content_object_data['commonsLibraryLocation_t'].blank?

    content_object_data['commonsLibraryLocation_t'].first
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

  def legislature
    return if content_object_data['legislature_ses'].blank?

    content_object_data['legislature_ses'].first
  end

  def registered_interest_declared
    return if content_object_data['registeredInterest_b'].blank?

    content_object_data['registeredInterest_b'].first == 'true' ? 'Yes' : 'No'
  end

  def external_location_uri
    return if content_object_data['externalLocation_uri'].blank?

    content_object_data['externalLocation_uri'].first
  end

  def internal_location_uri
    return if content_object_data['internalLocation_uri'].blank?

    content_object_data['internalLocation_uri'].first
  end

  def content_location_uri
    return if content_object_data['contentLocation_uri'].blank?

    content_object_data['contentLocation_uri'].first
  end

  def display_link
    # For everything else, where there is no externalLocation, no Link, internalLocation is not surfaced in new Search

    external_location_uri.blank? ? nil : external_location_uri
  end

  def has_link?
    # based on discussions, we are only displaying one link

    !display_link.blank?
  end

  def notes
    return if content_object_data['searcherNote_t'].blank?

    content_object_data['searcherNote_t'].first
  end

  def related_items
    relation_uris = content_object_data['relation_t']
    return if relation_uris.blank?

    related_objects = SolrMultiQuery.new(object_uris: relation_uris).object_data

    ret = []
    related_objects.each do |object|
      ret << ContentObject.generate(object)
    end

    ret
  end

  def parliamentary_session
    return if content_object_data['session_t'].blank?

    content_object_data['session_t'].first
  end

  def procedure
    return if content_object_data['procedural_ses'].blank?

    content_object_data['procedural_ses']
  end

  def member
    return if content_object_data['member_ses'].blank?

    content_object_data['member_ses'].first
  end

  def member_party
    return if content_object_data['memberParty_ses'].blank?

    content_object_data['memberParty_ses'].first
  end

  def answering_member
    return if content_object_data['answeringMember_ses'].blank?

    content_object_data['answeringMember_ses'].first
  end

  def lead_member
    return if content_object_data['leadMember_ses'].blank?

    content_object_data['leadMember_ses'].first
  end

  def corporate_author
    return if content_object_data['corporateAuthor_ses'].blank?

    content_object_data['corporateAuthor_ses'].first
  end

  def contains_statistics?
    return if content_object_data['containsStatistics_b'].blank?

    return false unless content_object_data['containsStatistics_b'].first == 'true'

    true
  end

  def date
    # generic date field
    return if content_object_data['date_dt'].blank?

    valid_date_string = validate_date(content_object_data['date_dt'])
    return unless valid_date_string

    valid_date_string.to_date
  end

  def date_of_royal_assent
    return if content_object_data['dateOfRoyalAssent_dt'].blank?

    valid_date_string = validate_date(content_object_data['dateOfRoyalAssent_dt'].first)
    return unless valid_date_string

    valid_date_string.to_date
  end

  private

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
      when 420548
        'EPetition'
      when 347214
        'ObservationsOnAPetition'
      else
        'ContentObject'
      end
    when 347207
      'FormalProceeding'
    when 90587
      'CommandPaper'
    when 91561
      'HouseOfCommonsPaper'
    when 92347
      'ParliamentaryPaperLaid'
    when 352156
      'ParliamentaryPaperReported'
    when 51288
      'UnprintedPaper'
    when 352261
      'UnprintedCommandPaper'
    when 363376
      'ResearchMaterial'
    when 92277
      'OralQuestion'
    when 286676
      'OralAnswerToQuestion'
    when 356748
      'OralQuestionTimeIntervention'
    when 356750
      'ProceedingContribution'
    when 352161
      'GrandCommitteeProceeding'
    when 352151
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

  def validate_date(date)
    begin
      date_string = Date.parse(date)
    rescue Date::Error
      return nil
    end

    date_string
  end

end