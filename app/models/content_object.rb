class ContentObject

  attr_reader :content_object_data

  def initialize(content_object_data)
    @content_object_data = content_object_data
  end

  def self.generate(content_object_data)
    # takes object data as an argument and returns an instance of the correct object subclass

    content_type_ses_id = content_object_data['type_ses'].first

    content_object_class(content_type_ses_id).classify.constantize.new(content_object_data)
  end

  def page_title
    # We set the page title and the content type.
    content_object_data['title_t']
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
      'Fallback'
    end
  end

end