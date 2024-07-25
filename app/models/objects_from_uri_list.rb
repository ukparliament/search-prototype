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
    sorted_data = data.sort { |a, b| a['date_dt'] <=> b['date_dt'] }

    ret[:items] = []
    sorted_data.each do |object|
      ret[:items] << ContentObject.generate(object)
    end

    ret
  end

  private

  def valid_input
    # must be an array of strings
    !relation_uris.blank? && relation_uris.is_a?(Array) && relation_uris.map(&:class).uniq.compact == [String]
  end

end
