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

end