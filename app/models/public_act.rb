class PublicAct < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/public_act'
  end

  def object_name
    'public act'
  end

  def bill
    # unsure about this - just grabbing first ID from legislation_ses
    legislation&.first
  end

end