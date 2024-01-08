class ObjectsFromUriList

  attr_reader :relation_uris

  def initialize(relation_uris)
    @relation_uris = relation_uris
  end

  def get_objects
    return if relation_uris.blank?

    # must be an array of strings
    return unless relation_uris.is_a?(Array)

    return unless relation_uris.map(&:class).uniq.compact == [String]

    ret = {}

    query = SolrMultiQuery.new(object_uris: relation_uris)
    relation_ses_ids = query.all_ses_ids

    unless relation_ses_ids.blank?
      ret[:ses_lookup] = SesLookup.new(relation_ses_ids).data
    end

    ret[:items] = []
    query.object_data.each do |object|
      ret[:items] << ContentObject.generate(object)
    end

    ret
  end
end
