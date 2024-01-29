class ResearchBriefing < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/research_briefing'
  end

  def html_summary
    get_first_as_html_from('htmlsummary_t')
  end

  def object_name
    subtype
  end

  def creator
    get_first_from('creator_ses')
  end

  def contributor
    get_first_from('contributor_ses')
  end

  def series
    get_first_from('category_ses')
  end

  def creator_party
    get_first_from('creatorParty_ses')
  end

  def is_published
    get_first_as_boolean_from('published_b')
  end

  def published_by
    # this is the publishing organisation and is to be used in the secondary attributes
    # currently unused as we're showing a graphic as per the wireframes, & working with publisherSnapshot_s to do that

    get_first_from('publisher_ses')
  end

  def last_updated
    get_first_as_date_from('modified_dt')
  end

  def display_link
    # For Research briefings link to externalLocation if present, internalLocation if no externalLocation is available.

    external_location_uri.blank? ? internal_location_uri : external_location_uri
  end
end