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
    requires_ses_data = true

    if field_name.downcase == "answeredby"
      ses_fields = %w[answeringMember_ses answeringDept_ses askedToReplyAuthor_ses]
    elsif field_name.downcase == "answeringmember"
      ses_fields = %w[answeringMember_ses]
    elsif field_name.downcase == "answeringmemberparty"
      ses_fields = %w[answeringMemberParty_ses]
    elsif field_name.downcase == "answertext"
      text_fields = %w[answerText_t]
    elsif field_name.downcase == "askedby"
      ses_fields = %w[tablingMember_ses askingMember_ses]
      text_fields = %w[tablingMemberPrinted_t askingMemberPrinted_t]
    elsif field_name.downcase == "author"
      text_fields = %w[creator_t contributor_t corporateAuthor_t department_t]
      ses_fields = %w[creator_ses contributor_ses corporateAuthor_ses section_ses tablingMember_ses askingMember_ses answeringMember_ses department_ses member_ses leadMember_ses]
    elsif field_name.downcase == "certifiedcategory"
      ses_fields = %w[certifiedCategory_ses]
    elsif field_name.downcase == "chair"
      fixed_fields = %w[chair]
      requires_ses_data = false
    elsif field_name.downcase == "chamberorcommittee"
      ses_fields = %w[place_ses]
    elsif field_name.downcase == "comingintoforce"
      date_fields = %w[comingIntoForce_dt]
      requires_ses_data = false
    elsif field_name.downcase == "commonsapproved"
      date_fields = %w[dateApproved_dt]
      requires_ses_data = false
    elsif field_name.downcase == "contributor"
      ses_fields = %w[contributor_ses]
    elsif field_name.downcase == "corrected"
      boolean_fields = %w[correctedWmsMc_b]
      requires_ses_data = false
    elsif field_name.downcase == "date"
      date_fields = %w[date_dt]
      requires_ses_data = false
    elsif field_name.downcase == "dateanswered"
      date_fields = %w[dateOfAnswer_dt]
      requires_ses_data = false
    elsif field_name.downcase == "datecertified"
      date_fields = %w[dateCertified_dt]
      requires_ses_data = false
    elsif field_name.downcase == "dateforanswer"
      date_fields = %w[dateForAnswer_dt]
      requires_ses_data = false
    elsif field_name.downcase == "datemade"
      date_fields = %w[dateMade_dt]
      requires_ses_data = false
    elsif field_name.downcase == "dateoriginated"
      date_fields = %w[dateOfOrigin_dt]
      requires_ses_data = false
    elsif field_name.downcase == "datereceived"
      date_fields = %w[dateReceived_dt]
      requires_ses_data = false
    elsif field_name.downcase == "datesigned"
      date_fields = %w[dateSigned_dt amendment_dateSigned_dt]
      requires_ses_data = false
    elsif field_name.downcase == "datesponsored"
      date_fields = %w[dateSponsored_dt amendment_dateSponsored_dt]
      requires_ses_data = false
    elsif field_name.downcase == "datetabled"
      date_fields = %w[dateTabled_dt amendment_dateTabled_dt]
      requires_ses_data = false
    elsif field_name.downcase == "dept"
      ses_fields = %w[department_ses answeringDept_ses]
      text_fields = %w[department_t]
    elsif field_name.downcase == "ecno"
      text_fields = %w[eCDocument_t]
    elsif field_name.downcase == "explanatorymemorandum"
      boolean_fields = %w[containsEM_b]
      requires_ses_data = false
    elsif field_name.downcase == "failedoral"
      boolean_fields = %w[failedOral_b]
      requires_ses_data = false
    elsif field_name.downcase == "from"
      fixed_fields = %w[fromdate]
      requires_ses_data = false
    elsif field_name.downcase == "groupedanswer"
      boolean_fields = %w[groupedAnswer_b]
      requires_ses_data = false
    elsif field_name.downcase == "holdinganswer"
      boolean_fields = %w[holdingAnswer_b]
      requires_ses_data = false
    elsif field_name.downcase == "house"
      ses_fields = %w[legislature_ses]
    elsif field_name.downcase == "impactassessment"
      boolean_fields = %w[containsIA_b]
      requires_ses_data = false
    elsif field_name.downcase == "primarymemberparty"
      ses_fields = %w[leadMemberParty_ses]
    elsif field_name.downcase == "leadmember"
      ses_fields = %w[leadMember_ses]
    elsif field_name.downcase == "leadmemberparty"
      ses_fields = %w[leadMemberParty_ses]
    elsif field_name.downcase == "legislature"
      ses_fields = %w[legislature_ses]
    elsif field_name.downcase == "legstage"
      ses_fields = %w[legislativeStage_ses]
    elsif field_name.downcase == "legtitle"
      ses_fields = %w[legislationTitle_ses]
      text_fields = %w[legislationTitle_t]
    elsif field_name.downcase == "libraryloc"
      text_fields = %w[lordsLibraryLocation_t commonsLibraryLocation_t physicalLocationCommons_t physicalLocationLords_t]
    elsif field_name.downcase == "lordsapproved"
      date_fields = %w[lordsApprovedDate_dt]
      requires_ses_data = false
    elsif field_name.downcase == "member"
      ses_fields = %w[member_ses]
    elsif field_name.downcase == "memberparty"
      ses_fields = %w[memberParty_ses]
    elsif field_name.downcase == "notreached"
      boolean_fields = %w[failedOral_b]
      requires_ses_data = false
    elsif field_name.downcase == "notes"
      text_fields = %w[searcherNote_t comingIntoForceNotes_t relatedItemNote_t]
    elsif field_name.downcase == "opqtype"
      text_fields = %w[contributionType_s contributionType_t]
      fixed_fields = %w[opqtype]
    elsif field_name.downcase == "othersponsor"
      ses_fields = %w[sponsor_ses amendment_sponsor_ses]
    elsif field_name.downcase == "place"
      ses_fields = %w[place_ses]
    elsif field_name.downcase == "primarymember"
      ses_fields = %w[primaryMember_ses]
    elsif field_name.downcase == "primarysponsor"
      ses_fields = %w[primarySponsor_ses amendment_primarySponsor_ses]
    elsif field_name.downcase == "procedural"
      ses_fields = %w[procedural_ses]
    elsif field_name.downcase == "procedure"
      ses_fields = %w[procedural_ses]
    elsif field_name.downcase == "prorogationanswer"
      boolean_fields = %w[prorogationAnswer_b]
      requires_ses_data = false
    elsif field_name.downcase == "publisher"
      ses_fields = %w[publisher_ses]
      text_fields = %w[publisher_t]
    elsif field_name.downcase == "questiontext"
      text_fields = %w[questionText_t]
    elsif field_name.downcase == "ref"
      text_fields = %w[identifier_t uin_t reference_t]
    elsif field_name.downcase == "reginterest"
      boolean_fields = %w[registeredInterest_b]
      requires_ses_data = false
    elsif field_name.downcase == "resolutionprocedure"
      text_fields = %w[procedure_s]
    elsif field_name.downcase == "section"
      ses_fields = %w[section_ses]
    elsif field_name.downcase == "session"
      transformations = %w[session]
      requires_ses_data = false
    elsif field_name.downcase == "signedby"
      ses_fields = %w[signedMember_ses amendment_signedMember_ses]
    elsif field_name.downcase == "stats"
      boolean_fields = %w[containsStatistics_b statisticsIndicated_b hasTable_b]
      requires_ses_data = false
    elsif field_name.downcase == "status"
      transformations = %w[status]
      requires_ses_data = false
    elsif field_name.downcase == "subject"
      text_fields = %w[subject_t]
      ses_fields = %w[subject_ses]
    elsif field_name.downcase == "summary"
      text_fields = %w[abstract_t]
    elsif field_name.downcase == "tabledby"
      ses_fields = %w[tablingMember_ses]
    elsif field_name.downcase == "timestamp"
      transformations = %w[timestamp]
      requires_ses_data = false
    elsif field_name.downcase == "title"
      text_fields = %w[title_t]
    elsif field_name.downcase == "to"
      fixed_fields = %w[todate]
      requires_ses_data = false
    elsif field_name.downcase == "topic" # TODO: add support for multiple SES queries so we can retrieve topic terms when needed, as is the case here
      ses_fields = %w[topic_ses]
    elsif field_name.downcase == "transferred"
      boolean_fields = %w[transferredQuestion_b]
      requires_ses_data = false
    elsif field_name.downcase == "type"
      ses_fields = %w[type_sesrollup]
    elsif field_name.downcase == "uin"
      text_fields = %w[uin_t]
    elsif field_name.downcase == "unprintedlead"
      boolean_fields = %w[unprintedLead_b]
      requires_ses_data = false
    elsif field_name.downcase == "unstarred"
      boolean_fields = %w[unstarredQuestion_b]
      requires_ses_data = false
    elsif field_name.downcase == "witness"
      ses_fields = %w[witness_ses]
      text_fields = %w[witness_t]
    elsif field_name.downcase == "wpqtype"
      fixed_fields = %w[wpqtype]
      requires_ses_data = false
    elsif field_name.match(/\w+_dt/)
      # if searching a _dt field specifically, treat it as a date field so that 'lastweek' etc. all work
      date_fields = [field_name]
      requires_ses_data = false
    elsif field_name.match(/\w+_ses/)
      # SES ID fields are minimally processed (the user is expected to provide a SES ID)
      ses_id_fields = [field_name]
    elsif field_name.downcase == "none"
      # include terms with no field specified
      process_without_field = true
      # any SES IDs related to terms will be applied to all_ses
      ses_fields = ["all_ses"]
    else
      text_fields = [field_name]
    end

    {
      text_fields: text_fields,
      ses_fields: ses_fields,
      ses_id_fields: ses_id_fields,
      boolean_fields: boolean_fields,
      date_fields: date_fields,
      fixed_fields: fixed_fields,
      transformations: transformations,
      process_without_field: process_without_field,
      requires_ses_data: requires_ses_data
    }
  end
end