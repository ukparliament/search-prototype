class ObjectsFromUriList

  attr_reader :relation_uris

  def initialize(relation_uris)
    @relation_uris = relation_uris
  end

  def get_objects
    return unless valid_input

    puts "Get #{relation_uris.size} objects..." if Rails.env.development?
    start_time = Time.now

    ret = {}
    ret[:items] = []
    threads = []

    relation_uris.each_slice(500) do |slice|
      threads << Thread.new do
        puts "Begin thread" if Rails.env.development?
        data = SolrMultiQuery.new(object_uris: slice).object_data
        sorted_data = data.sort { |a, b| a['date_dt'] <=> b['date_dt'] }
        sorted_data.each do |object|
          ret[:items] << ContentObject.generate(object)
        end
      end
    end

    threads.each(&:join)
    puts "All requests completed in #{Time.now - start_time} seconds" if Rails.env.development?

    ret
  end

  private

  def valid_input
    # must be an array of strings
    !relation_uris.blank? && relation_uris.is_a?(Array) && relation_uris.map(&:class).uniq.compact == [String]
  end

end
