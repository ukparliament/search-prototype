# # The one and only search controller.
class SearchController < ApplicationController

  def index
    @page_title = "Search results"
    @search = SolrSearch.new(search_params)
    @results = @search.object_data

    ses_ids = { value: @results.pluck('all_ses').flatten }
    @ses_data = SesLookup.new([ses_ids]).data unless ses_ids.blank?
  end

  private

  def search_params
    params.permit(:commit, :query, :page, filter: [:field_name, :value])
  end
end
