# # The one and only search controller.
class SearchController < ApplicationController

  def index
    @page_title = "Search results"
    @items = SolrSearch.new(search_params).object_data

    # TODO: this information should be included with the response, otherwise we're searching multiple times to get it
    # @metadata = results.send(:evaluated_response)['response']
  end

  private

  def search_params
    params.permit(:query, :page, :type)
  end
end
