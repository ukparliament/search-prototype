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
    text_fields, ses_fields, ses_id_fields, boolean_fields, date_fields = [], [], [], [], []
    process_without_field = false

    if field_name == "title"
      text_fields = %w[title_t]
    elsif field_name == "subject"
      # TODO: exclude TPG
      text_fields = %w[subject_t]
      ses_fields = %w[subject_ses]
    elsif field_name == "author"
      # extra: correspondingMinister_t, epCommittee_t, department_t etc are all only the submitted term (dwp) in example, whereas we're searching all equivalents too
      # this seems to be unintentional behaviour in the original search code; for the time being we're leaving this alone
      text_fields = %w[creator_t contributor_t corporateAuthor_t epCommittee_t department_t correspondingMinister_t]
      ses_fields = %w[creator_ses contributor_ses corporateAuthor_ses mep_ses section_ses tablingMember_ses askingMember_ses answeringMember_ses department_ses member_ses leadMember_ses correspondingMinister_ses]
    elsif field_name == "explanatorymemorandum"
      boolean_fields = %w[containsEM_b]
    elsif field_name == "datecertified"
      date_fields = %w[dateCertified_dt certifiedDate_dt]
    elsif field_name == "date"
      date_fields = %w[date_dt]
    elsif field_name == "answeredby"
      ses_fields = %w[answeringMember_ses answeringDept_ses askedToReplyAuthor_ses]
    elsif field_name == "askedby"
      ses_fields = %w[tablingMember_ses askingMember_ses]
    elsif field_name == "dept"
      ses_fields = %w[department_ses answeringDept_ses]
      text_fields = %w[department_t]
    elsif field_name == "primarymember"
      ses_fields = %w[primaryMember_ses]
    elsif field_name == "legtitle"
      # TODO: this alias needs to exclude SES class TPG; will have to be implemented elsewhere?
      ses_fields = %w[legislationTitle_ses]
      text_fields = %w[legislationTitle_t]
    elsif field_name == "legstage"
      ses_fields = %w[legislativeStage_ses]
    elsif field_name == "house"
      ses_fields = %w[legislature_ses]
    elsif field_name == "member"
      ses_fields = %w[member_ses]
    elsif field_name == "primarysponsor"
      ses_fields = %w[primarySponsor_ses amendment_primarySponsor_ses]
    elsif field_name == "publisher"
      ses_fields = %w[publisher_ses]
      text_fields = %w[publisher_t]
    elsif field_name == "type"
      ses_fields = %w[type_sesrollup]
    elsif field_name == "tabledby"
      ses_fields = %w[tablingMember_ses]
    elsif field_name.match(/\w+_dt/)
      # if searching a _dt field specifically, treat it as a date field so that 'lastweek' etc. all work
      date_fields = [field_name]
    elsif field_name.match(/\w+_ses/)
      ses_id_fields = [field_name]
    elsif field_name == "none"
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
      process_without_field: process_without_field
    }
  end
end