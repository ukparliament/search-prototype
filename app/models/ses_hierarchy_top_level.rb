class SesHierarchyTopLevel < SesLookup
  BASE_API_URL = "https://api.parliament.uk/ses/"

  # An alternative approach to retrieving hierarchy IDs - currently unused

  def initialize() end

  def get_response
    parsed_response = JSON.parse(api_response(346696))
    get_id_and_children(parsed_response.dig('terms'))
  end

  def get_id_and_children(data)
    ret = {}

    data.each do |hash|
      id = hash.dig('term', 'id')
      child_id_array = hash.dig('term', 'hierarchy').last.dig('fields')
      child_ids = []
      child_id_array.each do |child_hash|
        child_ids << child_hash.dig('field', 'id')
      end

      ret[id] = child_ids
    end

    ret
  end

  def ruby_uri(id)
    build_uri("#{BASE_API_URL}select.exe?TBDB=disp_taxonomy&TEMPLATE=service.json&SERVICE=browse&HIERTYPE=NT&expand_hierarchy=1&ID=#{id}")
  end

  private

  def api_response(id)
    raise 'Please stub this method to avoid HTTP requests in test environment' if Rails.env.test?

    api_get_request(ruby_uri(id))
  end
end