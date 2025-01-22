class Proceeding < ContentTypeObject

  def initialize(content_type_object_data)
    super
  end

  def object_name
    subtype_or_type
  end

  def legislative_stage
    get_all_from('legislativeStage_ses')
  end
end