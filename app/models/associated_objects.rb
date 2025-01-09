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

  def solr_fields
    # the fields we want for associated objects
    # TODO: will come back to this

    # ideally we can dispense with all_ses

    'uri type_ses subtype_ses member_ses legislature_ses questionText_t answerText_t correctingMember_ses correctingMemberParty_ses department_ses'
  end

  def ses_fields
    # across all search result page associated objects, the only SES IDs are for asking members / parties on questions
    %w[askingMember_ses askingMemberParty_ses]
  end

  def get_associated_objects
    puts "Fetching objects associated with the search results" if Rails.env.development?
    associated_objects = SolrQueryWrapper.new(object_uris: associated_object_ids, solr_fields: solr_fields).get_objects
    return {} if associated_objects.blank?

    associated_objects.dig(:items)
  end

  def data
    ret = {}
    obj = get_associated_objects

    obj_ses_ids = obj.map { |ao| ao.content_object_data.select { |k| ses_fields.include?(k) }.values }.flatten.uniq

    obj_data = {}
    obj.each do |o|
      obj_data[o.object_uri[:value]] = o
    end

    ret[:object_data] = obj_data
    ret[:ses_ids] = obj_ses_ids

    ret
  end
end