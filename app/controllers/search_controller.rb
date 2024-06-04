# # The one and only search controller.
class SearchController < ApplicationController

  def index
    @page_title = "Search results"
    search = SolrSearch.new(search_params).data
    @search_data = SearchData.new(search)

    if @search_data.solr_error?
      render template: @search_data.error_partial_path, locals: { status: @search_data.error_code,
                                                                  message: @search_data.error_message }
    else
      @ses_data = @search_data.ses_data
      @hierarchy_builder = HierarchyBuilder.new(@search_data.content_type_rollup_ids)
      @hierarchy_data = @hierarchy_builder.hierarchy_data
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
