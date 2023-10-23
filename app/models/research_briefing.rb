class ResearchBriefing < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/research_briefing'
  end

  def object_name
    'research briefing'
  end

  def ses_lookup_ids
    [
      subjects,
      legislation,
      legislature,
      department,
      type,
      subtype,
      creator,
      creator_party
    ]
  end

  def html_summary
    return if content_object_data['htmlsummary_t'].blank?

    CGI::unescapeHTML(content_object_data['htmlsummary_t'].first)
  end

  def creator
    # this is for the prelim 'by...'

    return if content_object_data['creator_ses'].blank?

    content_object_data['creator_ses'].first
  end

  def creator_party
    # this is for the prelim 'by...'

    return if content_object_data['creatorParty_ses'].blank?

    content_object_data['creatorParty_ses'].first
  end

  def published_by
    # this is the publishing organisation and is to be used in the secondary attributes
    # currently unused as we're showing a graphic as per the wireframes, & working with publisherSnapshot_s to do that

    return if content_object_data['publisher_ses'].blank?

    content_object_data['publisher_ses'].first
  end

  def publisher_string
    # this is looking at a string (rather than SES id) for publisher in order to pick the correct graphic
    # this feels quite fragile and should be given further thought

    return if content_object_data['publisherSnapshot_s'].blank?

    content_object_data['publisherSnapshot_s'].first
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

  def publisher_logo_partial
    # TODO: investigate CSS approach
    # TODO: validate publisher names against accepted list?

    return unless publisher_string

    "/search/logo_svgs/#{publisher_string.parameterize}"
  end

  def updated_on
    return if content_object_data['dateLastModified_dt'].blank?

    valid_date_string = validate_date(content_object_data['dateLastModified_dt'].first)
    return unless valid_date_string

    valid_date_string.to_date
  end

  def display_link
    # For Research briefings link to externalLocation if present, internalLocation if no externalLocation is available.

    external_location_uri.blank? ? internal_location_uri : external_location_uri
  end
end