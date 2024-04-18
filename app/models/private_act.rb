class PrivateAct < Act

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/private_act'
  end

  def search_result_partial
    'search/results/private_act'
  end
end