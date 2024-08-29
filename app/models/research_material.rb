class ResearchMaterial < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/research_material'
  end

  def search_result_partial
    'search/results/research_material'
  end
end