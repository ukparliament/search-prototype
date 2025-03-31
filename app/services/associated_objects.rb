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
    puts "Fetching associated objects" if Rails.env.development?
    solr_fields_string = solr_fields.flatten.uniq.join(' ')
    associated_objects = SolrQueryWrapper.new(object_uris: associated_object_ids, solr_fields: solr_fields_string).get_objects
    return {} if associated_objects.blank?

    associated_objects.dig(:items)
  end

  def ses_fields
    solr_fields.select do |field|
      field.last(4) == "_ses"
    end
  end

  def data
    ret = {}
    obj = get_associated_objects

    obj_ses_ids = obj.map { |ao| ao.content_type_object_data.select { |k| ses_fields.include?(k) }.values }.flatten.uniq

    obj_data = {}
    obj.each do |o|
      obj_data[o.object_uri[:value]] = o
    end

    ret[:object_data] = obj_data
    ret[:ses_ids] = obj_ses_ids

    ret
  end
end