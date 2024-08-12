class AssociatedObjects
  def initialize(objects)
    @objects = objects
  end

  def normalised_objects
    [@objects].flatten
  end

  def associated_object_ids
    @associated_object_ids ||= normalised_objects.map { |o| o.associated_objects }.compact.flatten.uniq
  end

  def get_associated_objects
    associated_objects = ObjectsFromUriList.new(associated_object_ids).get_objects
    return {} if associated_objects.blank?

    associated_objects.dig(:items)
  end

  def data
    ret = {}

    obj = get_associated_objects

    obj_ses_ids = obj.flat_map(&:ses_lookup_ids)

    obj_data = {}
    obj.each do |o|
      obj_data[o.object_uri[:value]] = o
    end

    ret[:object_data] = obj_data
    ret[:ses_ids] = obj_ses_ids

    ret
  end
end