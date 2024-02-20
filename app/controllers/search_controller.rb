# # The one and only search controller.
class SearchController < ApplicationController

  def index
    @page_title = "Search results"
    @search = SolrSearch.new(search_params)
    @response = @search.all_data

    if @response['code']
      render template: 'content_objects/error', locals: { status: @response['code'], message: @response['msg'] }
    else
      @results = @response['docs']
      @number_of_results = @response['numFound']
      @start = @response['start']
      @end = @response['start'] + @search.rows

      ses_ids = { value: @results.pluck('all_ses').flatten }
      @ses_data = SesLookup.new([ses_ids]).data unless ses_ids.blank?
    end
  end

  private

  def search_params
    params.permit(:commit, :query, :page, filter: [:field_name, :value])
  end
end
