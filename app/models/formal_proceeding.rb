class FormalProceeding < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/formal_proceeding'
  end

  def object_name
    # wireframe shows 'legislative formal proceeding (first reading)'
    # unsure how this applies
    'formal proceeding'
  end

end