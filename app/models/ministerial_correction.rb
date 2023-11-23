class MinisterialCorrection < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/ministerial_correction'
  end

  def object_name
    'ministerial correction'
  end

  def correction_text
    get_first_from('correctionText_t')
  end

  def correcting_member
    member
  end

  def correcting_member_party
    member_party
  end

  def correction_date
    date
  end
end