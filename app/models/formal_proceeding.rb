class FormalProceeding < Proceeding

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/formal_proceeding'
  end

  def search_result_partial
    'search/results/formal_proceeding'
  end

end