class ContentObject

  attr_reader :content_object_data

  def initialize(content_object_data)
    @content_object_data = content_object_data
  end

  def self.generate(content_object_data)
    # takes object data as an argument and returns an instance of the correct object subclass

    content_type_ses_id = content_object_data['type_ses']&.first

    content_object_class(content_type_ses_id).classify.constantize.new(content_object_data)
  end

  def ses_lookup_ids
    # TODO: refactor so subclasses access this method rather than simply override it
    [
      type,
      subtype,
      subjects,
      legislation,
      legislature,
      department
    ]
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
    # We set the page title and the content type.
    content_object_data['title_t']
  end

  def ses_data
    SesLookup.new(ses_lookup_ids).data
  end

  def content
    return if content_object_data['content_t'].blank?

    CGI::unescapeHTML(content_object_data['content_t'].first)
  end

  def reference
    # typically used for Hansard col refs
    return if content_object_data['identifier_t'].blank?

    content_object_data['identifier_t'].first
  end

  def subjects
    return if content_object_data['subject_ses'].blank?

    content_object_data['subject_ses']
  end

  def topics
    # note - have not yet verified key as missing from test data
    return if content_object_data['topic_ses'].blank?

    content_object_data['topic_ses']
  end

  def legislation
    return if content_object_data['legislationTitle_ses'].blank?

    content_object_data['legislationTitle_ses']
  end

  def department
    return if content_object_data['department_ses'].blank?

    content_object_data['department_ses'].first
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

    content_object_data['searcherNote_t']
  end

  def related_items
    # based on provided information, this will return one or more URIs of related item object pages

    # if relation_t and relation_uri, gets a related item
    # fields might be inconsistent
    # link through to the item landing page

    return if content_object_data['relation_t'].blank?

    content_object_data['relation_t']
  end

  def session
    return if content_object_data['session_t'].blank?

    content_object_data['session_t'].first
  end

  private

  def self.content_object_class(ses_id)
    case ses_id
    when 90996
      'Edm'
    when 346697
      'ResearchBriefing'
    when 93522
      'WrittenQuestion'
    when 352211
      'WrittenStatement'
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