class EuropeanDepositedDocument < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/european_deposited_document'
  end

  def object_name
    'european deposited document'
  end

end