# # The one and only search controller.
class SearchController < ApplicationController
  before_action :begin_timer

  def index
    @page_title = "Search results"
    @search_data = SearchData.new(SolrSearch.new(search_params).data)

    if @search_data.solr_error?
      render template: @search_data.error_partial_path, locals: { status: @search_data.error_code, message: @search_data.error_message }
    else
      @ses_data = @search_data.ses_data
    end
  end

  private

  def begin_timer
    @start_time = Time.now
  end

  def search_params
    params.permit(:commit, :query, :page, :results_per_page, :sort_by, :expanded_types, :toggled_facets,
                  :show_detailed, filter: permitted_filters)
  end

  def permitted_filters
    hash = {}
    SolrSearch.facet_fields.each do |field|
      hash[field.to_sym] = []
    end

    hash
  end
end
