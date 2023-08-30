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

  def correction?
    # TODO: based on what?
    true
  end
end