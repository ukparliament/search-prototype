# # The one and only search controller.
class SearchController < ApplicationController

  def index
    @page_title = "Search results"
    results = SolrSearch.new(search_params)

    @items = results.object_data
    @metadata = results.send(:evaluated_response)['response']
  end

  private

  def search_params
    params.permit(:query, :page, :type_ses)
  end
end
