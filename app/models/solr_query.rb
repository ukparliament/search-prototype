class SolrQuery < ApiCall
  def initialize(params)
    super
  end

  def object_data
    return evaluated_response if evaluated_response['statusCode'] == 500

    evaluated_response['response']['docs'].first
  end

  def ruby_uri
    build_uri("#{BASE_API_URI}select?q=uri:%22#{object_uri}%22")
  end
end