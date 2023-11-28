# # The one and only search controller.
class SearchController < ApplicationController

  def index
    @page_title = "Search results"
    query = SolrSearch.new(params)

    @items = query.object_data
    @ses_data = SesLookup.new([query.filter]).data unless query.filter.blank?

    # TODO: this information should be included with the response, otherwise we're searching multiple times to get it
    # @metadata = results.send(:evaluated_response)['response']
  end

  private

  def search_params
    params.permit(:query, :page, filter: [])
  end
end
