# frozen_string_literal: true

##
# FieldExpander accepts a string field name and returns a Ruby hash of field categories (keys) and Solr field names
# (values, in an array). This class is used to expand a user's search query across other fields behind the scenes,
# as part of query expansion.

class FieldExpander
  attr_reader :field_name

  def initialize(field_name)
    @field_name = field_name
  end

  ##
  # Populates text_fields, ses_fields (fields to search the preferred term SES ID,
  # retrieved from SES), ses_id_fields (fields to search with a user-provided SES ID), boolean_fields and date_fields
  # arrays based on initial field name. Returns as a hash keyed to category name.
  def expand_fields
    text_fields, ses_fields, ses_id_fields, boolean_fields, date_fields, fixed_fields, transformations = [], [], [], [], [], [], []
    process_without_field = false

    if field_name == "answeredby"
      ses_fields = %w[answeringMember_ses answeringDept_ses askedToReplyAuthor_ses]
    elsif field_name == "answertext"
      text_fields = %w[answerText_t]
    elsif field_name == "askedby"
      ses_fields = %w[tablingMember_ses askingMember_ses]
      text_fields = %w[tablingMemberPrinted_t askingMemberPrinted_t]
    elsif field_name == "author"
      text_fields = %w[creator_t contributor_t corporateAuthor_t department_t]
      ses_fields = %w[creator_ses contributor_ses corporateAuthor_ses section_ses tablingMember_ses askingMember_ses answeringMember_ses department_ses member_ses leadMember_ses]
    elsif field_name == "certifiedcategory"
      ses_fields = %w[certifiedCategory_ses]
    elsif field_name == "chair"
      fixed_fields = %w[chair]
    elsif field_name == "comingintoforce"
      date_fields = %w[comingIntoForce_dt]
    elsif field_name == "commonsapproved"
      date_fields = %w[dateApproved_dt]
    elsif field_name == "contributor"
      ses_fields = %w[contributor_ses]
    elsif field_name == "corrected"
      boolean_fields = %w[correctedWmsMc_b]
    elsif field_name == "date"
      date_fields = %w[date_dt]
    elsif field_name == "dateanswered"
      date_fields = %w[dateOfAnswer_dt]
    elsif field_name == "datecertified"
      date_fields = %w[dateCertified_dt]
    elsif field_name == "dateforanswer"
      date_fields = %w[dateForAnswer_dt]
    elsif field_name == "datemade"
      date_fields = %w[dateMade_dt]
    elsif field_name == "dateoriginated"
      date_fields = %w[dateOfOrigin_dt]
    elsif field_name == "datereceived"
      date_fields = %w[dateReceived_dt]
    elsif field_name == "datesigned"
      date_fields = %w[dateSigned_dt amendment_dateSigned_dt]
    elsif field_name == "datesponsored"
      date_fields = %w[dateSponsored_dt amendment_dateSponsored_dt]
    elsif field_name == "datetabled"
      date_fields = %w[dateTabled_dt, amendment_dateTabled_dt ]
    elsif field_name == "dept"
      date_fields = %w[department_ses answeringDept_ses]
      text_fields = %w[department_t]
    elsif field_name == "ecno"
      text_fields = %w[eCDocument_t]
    elsif field_name == "explanatorymemorandum"
      boolean_fields = %w[containsEM_b]
    elsif field_name == "failedoral"
      boolean_fields = %w[failedOral_b]
    elsif field_name == "from"
      fixed_fields = %w[fromdate]
    elsif field_name == "groupedanswer"
      boolean_fields = %w[groupedAnswer_b]
    elsif field_name == "holdinganswer"
      boolean_fields = %w[holdingAnswer_b]
    elsif field_name == "impactassessment"
      boolean_fields = %w[containsIA_b]
    elsif field_name == "primarymemberparty"
      ses_fields = %w[leadMemberParty_ses]
    elsif field_name == "legislature"
      ses_fields = %w[legislature_ses]
    elsif field_name == "legstage"
      ses_fields = %w[legislativeStage_ses]
    elsif field_name == "legtitle"
      ses_fields = %w[legislationTitle_ses]
      text_fields = %w[legislationTitle_t]
    elsif field_name == "libraryloc"
      text_fields = %w[lordsLibraryLocation_t commonsLibraryLocation_t physicalLocationCommons_t physicalLocationLords_t]
    elsif field_name == "lordsapproved"
      date_fields = %w[lordsApprovedDate_dt]
    elsif field_name == "member"
      ses_fields = %w[member_ses]
    elsif field_name == "memberparty"
      ses_fields = %w[memberParty_ses]
    elsif field_name == "notes"
      text_fields = %w[searcherNote_t comingIntoForceNotes_t relatedItemNote_t]
    elsif field_name == "opqtype"
      text_fields = %w[contributionType_s contributionType_t]
      fixed_fields = %w[opqtype]
    elsif field_name == "othersponsor"
      ses_fields = %w[sponsor_ses amendment_sponsor_ses]
    elsif field_name == "place"
      ses_fields = %w[place_ses]
    elsif field_name == "primarysponsor"
      ses_fields = %w[primarySponsor_ses amendment_primarySponsor_ses]
    elsif field_name == "procedural"
      ses_fields = %w[procedural_ses]
    elsif field_name == "prorogationanswer"
      boolean_fields = %w[prorogationAnswer_b]
    elsif field_name == "publisher"
      ses_fields = %w[publisher_ses]
      text_fields = %w[publisher_t]
    elsif field_name == "questiontext"
      text_fields = %w[questionText_t]
    elsif field_name == "ref"
      text_fields = %w[identifier_t, uin_t, reference_t]
    elsif field_name == "reginterest"
      boolean_fields = %w[registeredInterest_b]
    elsif field_name == "resolutionprocedure"
      text_fields = %w[procedure_s]
    elsif field_name == "section"
      ses_fields = %w[section_ses]
    elsif field_name == "session"
      transformations = %w[session]
    elsif field_name == "signedby"
      ses_fields = %w[signedMember_ses amendment_signedMember_ses]
    elsif field_name == "stats"
      boolean_fields = %w[containsStatistics_b statisticsIndicated_b hasTable_b]
    elsif field_name == "status"
      transformations = %w[status]
    elsif field_name == "summary"
      text_fields = %w[abtract_t]
    elsif field_name == "tabledby"
      ses_fields = %w[tablingMember_ses]
    elsif field_name == "timestamp" # TODO: test behaviour / unit test relevant code
      transformations = %w[timestamp]
    elsif field_name == "to"
      fixed_fields = %w[todate]
    elsif field_name == "topic" # TODO: add support for multiple SES queries so we can retrieve topic terms when needed, as is the case here
      ses_fields = %w[topic_ses]
    elsif field_name == "transferred"
      boolean_fields = %w[transferredQuestion_b]
    elsif field_name == "type"
      ses_fields = %w[type_sesrollup]
    elsif field_name == "uin"
      text_fields = %w[uin_t]
    elsif field_name == "unprintedlead"
      boolean_fields = %w[unprintedLead_b]
    elsif field_name == "unstarred"
      boolean_fields = %w[unstarredQuestion_b]
    elsif field_name == "witness"
      ses_fields = %w[witness_ses]
      text_fields = %w[witness_t]
    elsif field_name == "wpqtype"
      fixed_fields = %w[wpqtype]
    elsif field_name.match(/\w+_dt/)
      # if searching a _dt field specifically, treat it as a date field so that 'lastweek' etc. all work
      date_fields = [field_name]
    elsif field_name.match(/\w+_ses/)
      # SES ID fields are minimally processed (the user is expected to provide a SES ID)
      ses_id_fields = [field_name]
    elsif field_name == "none"
      # include terms with no field specified
      process_without_field = true
      # any SES IDs related to terms will be applied to all_ses
      ses_fields = ["all_ses"]
    else
      text_fields = [field_name]
    end

    # aliases no longer listed in doc ??
    # elsif field_name == "title"
    #   text_fields = %w[title_t]
    # elsif field_name == "subject"  # no longer listed?
    #   text_fields = %w[subject_t]
    #   ses_fields = %w[subject_ses]
    # elsif field_name == "primarymember"
    #   ses_fields = %w[primaryMember_ses]
    # elsif field_name == "house"
    #   ses_fields = %w[legislature_ses]

    {
      text_fields: text_fields,
      ses_fields: ses_fields,
      ses_id_fields: ses_id_fields,
      boolean_fields: boolean_fields,
      date_fields: date_fields,
      fixed_fields: fixed_fields,
      transformations: transformations,
      process_without_field: process_without_field
    }
  end
end