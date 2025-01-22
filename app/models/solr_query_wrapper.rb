class SolrQueryWrapper
  attr_reader :object_uris, :solr_fields

  def initialize(params)
    @object_uris = params[:object_uris]
    @solr_fields = params[:solr_fields]
  end

  def get_objects
    # TODO: re-enable this
    # return unless valid_input

    puts "Get #{object_uris.size} objects..." if Rails.env.development?

    start_time = Time.now

    ret = {}
    ret[:items] = []
    threads = []

    unless object_uris.blank?
      object_uris.each_slice(500) do |slice|
        threads << Thread.new do
          puts "Begin thread" if Rails.env.development?
          data = SolrMultiQuery.new(object_uris: slice, field_list: solr_fields).object_data
          data.each do |object|
            ret[:items] << ContentTypeObject.generate(object)
          end
        end
      end
    end

    threads.each(&:join)
    puts "All requests completed in #{Time.now - start_time} seconds" if Rails.env.development?

    ret
  end

  private

  def valid_input
    return false if solr_fields.blank?
    return false unless solr_fields.is_a?(String)

    # must be an array of strings
    !object_uris.blank? && object_uris.is_a?(Array) && object_uris.map(&:class).uniq.compact == [String]
  end

end
