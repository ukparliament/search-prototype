class StatutoryInstrument < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/statutory_instrument'
  end

  def object_name
    "Statutory instrument"
  end

end