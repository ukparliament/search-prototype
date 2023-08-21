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

  def page_title
    # We set the page title and the content type.
    content_object_data['title_t']
  end

  def reference
    return if content_object_data['identifier_t'].blank?

    content_object_data['identifier_t'].first
  end

  def subjects
    return if content_object_data['subject_sesrollup'].blank?

    content_object_data['subject_sesrollup']
  end

  def legislation
    return if content_object_data['legislature_ses'].blank?

    content_object_data['legislature_ses']
  end

  def external_location_uri
    return if content_object_data['externalLocation_uri'].blank?

    content_object_data['externalLocation_uri'].first
  end

  def content_location_uri
    return if content_object_data['contentLocation_uri'].blank?

    content_object_data['contentLocation_uri'].first
  end

  def has_any_links?
    content_object_data['externalLocation_uri'].present?
    content_object_data['contentLocation_uri'].present?
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

end