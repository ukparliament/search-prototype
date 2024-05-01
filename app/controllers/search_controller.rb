# # The one and only search controller.
class SearchController < ApplicationController

  def index
    # TODO: refactor overstuffed controller action

    @page_title = "Search results"
    @search = SolrSearch.new(search_params)
    search_data = SearchData.new(@search)

    @all_data = @search.all_data

    if search_data.response.has_key?('code')
      if [401, 404].include?(search_data.response['code'])
        render template: "layouts/shared/error/#{search_data.response['code']}", locals: { status: search_data.response['code'], message: search_data.response['msg'] }
      else
        render template: 'layouts/shared/error/500', locals: { status: search_data.response['code'], message: search_data.response['msg'] }
      end
    else
      # TODO: consider placing all of this inside a single data hash to be read by views?

      @objects = []
      search_data.data.each do |object_data|
        @objects << ContentObject.generate(object_data)
      end

      @metadata = search_data.metadata
      @number_of_results = search_data.number_of_results
      @sort = search_data.sort
      @start = search_data.start
      @end = search_data.end
      @total_pages = search_data.total_pages
      @ses_data = search_data.ses_data
      @facets = search_data.facet_data
      @query_time = search_data.query_time
      @current_page = @search.current_page
      @requested_age = @search.user_requested_page

      # debug only
      @content_type_hierarchy = SesLookup.new([{ value: [92277] }]).data
      # @content_type_hierarchy = SesLookup.new([{ value: [346696] }]).data
    end
  end

  private

  def search_params
    params.permit(:commit, :query, :page, :results_per_page, :sort_by, filter: [permitted_filters])
  end

  def permitted_filters
    hash = {}
    SolrSearch.facet_fields.each do |field|
      hash[field.to_sym] = []
    end

    hash
  end
end
