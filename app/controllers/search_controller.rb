# # The one and only search controller.
class SearchController < ApplicationController

  def index
    @page_title = "Search results"
    @search = SolrSearch.new(search_params)
    @all_data = @search.all_data
    @response = @all_data['response']
    @facets = @all_data['facet_counts']

    if @response.has_key?('code')
      case @response['code']
      when 404
        render template: 'layouts/shared/error/404', locals: { status: @response['code'], message: @response['msg'] }
      when 500
        render template: 'layouts/shared/error/500', locals: { status: @response['code'], message: @response['msg'] }
      when 401
        render template: 'layouts/shared/error/401', locals: { status: @response['code'], message: @response['msg'] }
      else
        render template: 'layouts/shared/error/500', locals: { status: @response['code'], message: @response['msg'] }
      end
    else

      data = @response['docs']
      @objects = []
      data.each do |object_data|
        @objects << ContentObject.generate(object_data)
      end

      @metadata = @response.except('docs')
      @number_of_results = @response['numFound']
      @start = @response['start']
      @end = @response['start'] + @search.rows
      @total_pages = (@number_of_results / @search.rows) + 1 unless @number_of_results.blank?

      ses_ids = { value: data.pluck('all_ses').flatten.uniq }
      @ses_data = SesLookup.new([ses_ids]).data unless ses_ids.blank?
    end
  end

  private

  def search_params
    params.permit(:commit, :query, :page, filter: [:field_name, :value])
  end
end
