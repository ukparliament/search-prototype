class PaperPetition < Petition

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/paper_petition'
  end

  def object_name
    subtype
  end

  def content
    abstract_text.blank? ? petition_text : abstract_text
  end
end