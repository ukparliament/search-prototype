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
    text_fields, ses_fields, ses_id_fields, boolean_fields, date_fields, non_aliased_fields = [], [], [], [], [], []

    if field_name == "title"
      text_fields = ['title_t']
    elsif field_name == "subject"
      text_fields = ['subject_t']
      ses_fields = ['subject_ses']
      # topic_ses has been removed, so behaviour here differs from old search by design
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
    elsif field_name.match(/\w+_dt/)
      # if searching a _dt field specifically, treat it as a date field so that 'lastweek' etc. all work
      date_fields = [field_name]
    elsif field_name.match(/\w+_ses/)
      ses_id_fields = [field_name]
    elsif field_name == "none"
      non_aliased_fields = [field_name]
      # catches searches for strings or phrases with no specific field
      ses_fields = ["all_ses"]
    else
      text_fields = [field_name]
    end

    {
      'text_fields' => text_fields,
      'ses_fields' => ses_fields,
      'ses_id_fields' => ses_id_fields,
      'boolean_fields' => boolean_fields,
      'date_fields' => date_fields,
      'non_aliased_fields' => non_aliased_fields
    }
  end
end