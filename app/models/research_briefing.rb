class ResearchBriefing < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/research_briefing'
  end

  def object_name
    "research briefing"
  end

  def content
    return if content_object_data['content_t'].blank?

    content_object_data['content_t'].first
  end

  def html_summary
    return if content_object_data['htmlsummary_t'].blank?

    content_object_data['htmlsummary_t'].first
  end

  def published?
    return if content_object_data['published_b'].blank?

    return false unless content_object_data['published_b'].first == 'true'

    true
  end

  def published_by
    return if content_object_data['creator_ses'].blank?

    content_object_data['creator_ses'].first
  end

  def publisher
    return if content_object_data['publisherSnapshot_s'].blank?

    content_object_data['publisherSnapshot_s'].first
  end

  def publisher_logo_partial
    # TODO: validate publisher names against accepted list?

    return unless publisher

    "/search/logo_svgs/#{publisher.parameterize}"
  end

  def published_on
    return if content_object_data['created_dt'].blank?

    valid_date_string = validate_date(content_object_data['created_dt'].first)
    return unless valid_date_string

    valid_date_string.to_date
  end

  def updated_on
    return if content_object_data['dateLastModified_dt'].blank?

    valid_date_string = validate_date(content_object_data['dateLastModified_dt'].first)
    return unless valid_date_string

    valid_date_string.to_date
  end

  # topics data missing
  # def topics
  #   return if content_object_data[''].blank?
  #
  #   content_object_data['']
  # end

  private

  def validate_date(date)
    begin
      date_string = Date.parse(date)
    rescue Date::Error
      return nil
    end

    date_string
  end

end