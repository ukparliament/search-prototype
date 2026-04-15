class SolrQuery < ApiClient

  # Used to return the first result for item with given URI

  def initialize(params)
    super
  end

  def object_data
    # differs from superclass in that we want the first result regardless of type_ses presence
    object = all_data['response']['docs'].first

    if object.dig('type_ses').blank?
      # raise the appropriate error if type_ses is missing
      raise ExternalServiceNotFound
    else
      object
    end
  end

  private

  def search_params
    {
      "q": "uri:#{object_uri}"
    }
  end
end