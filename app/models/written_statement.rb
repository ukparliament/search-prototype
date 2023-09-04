class WrittenStatement < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/written_statement'
  end

  def object_name
    "written statement"
  end

  def attachment
    return if content_object_data['attachment_t'].blank?

    content_object_data['attachment_t'].first
  end

  def notes
    return if content_object_data['notes_t'].blank?

    content_object_data['notes_t'].first
  end

  def member
    return if content_object_data['member_ses'].blank?

    content_object_data['member_ses'].first
  end

  def member_party
    return if content_object_data['memberParty_ses'].blank?

    content_object_data['memberParty_ses'].first
  end

  def statement_date
    return if content_object_data['date_dt'].blank?

    valid_date_string = validate_date(content_object_data['date_dt'])
    return unless valid_date_string

    valid_date_string.to_date
  end

  def correction?
    # TODO: based on what?
    true
  end
end