class SolrQuery < ApiCall

  # Used to return the first result for item with given URI

  def initialize(params)
    super
  end

  def object_data
    super.first
  end

  private

  def search_params
    {
      "q": "uri:#{object_uri}"
      # "rows": 1,
      # "wt": "json"
    }
  end
end