# # The one and only search controller.
class SearchController < ApplicationController

  def index
    @page_title = "Search results"
    query = SolrSearch.new(params)

    @items = query.object_data
    @ses_data = SesLookup.new([query.filter]).data unless query.filter.blank?
  end

  private

  def search_params
    params.permit(:query, :page, filter: [])
  end
end
