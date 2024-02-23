# # The one and only search controller.
class SearchController < ApplicationController

  def index
    @page_title = "Search results"
    @search = SolrSearch.new(search_params)
    @response = @search.all_data

    if @response['statusCode']
      case @response['statusCode']
      when 404
        render template: 'layouts/shared/error/404', locals: { status: @response['statusCode'], message: @response['message'] }
      when 500
        render template: 'layouts/shared/error/500', locals: { status: @response['statusCode'], message: @response['message'] }
      when 401
        render template: 'layouts/shared/error/401', locals: { status: @response['statusCode'], message: @response['message'] }
      else
        raise 'unknown error occurred'
      end
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
