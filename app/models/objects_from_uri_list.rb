class ObjectsFromUriList

  attr_reader :relation_uris

  def initialize(relation_uris)
    @relation_uris = relation_uris
  end

  def get_objects
    return unless valid_input

    puts "Get #{relation_uris.size} objects..."

    ret = {}
    data = SolrMultiQuery.new(object_uris: relation_uris).object_data
    relation_ses_ids = all_ses_ids(data)

    unless relation_ses_ids.blank?
      ret[:ses_lookup] = SesLookup.new(relation_ses_ids).data
    end

    ret[:items] = []
    data.each do |object|
      ret[:items] << ContentObject.generate(object)
    end

    ret
  end

  def all_ses_ids(data)
    data.flat_map { |o| { value: o["all_ses"], field_name: "all_ses" } }.uniq
  end

  private

  def valid_input
    # must be an array of strings
    !relation_uris.blank? && relation_uris.is_a?(Array) && relation_uris.map(&:class).uniq.compact == [String]
  end

end
