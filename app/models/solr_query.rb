class SolrQuery < ApiCall
  def initialize(params)
    super
  end

  def object_data
    super.first
  end

  def ruby_uri
    build_uri("#{BASE_API_URL}select?q=uri:%22#{object_uri}%22")
  end
end