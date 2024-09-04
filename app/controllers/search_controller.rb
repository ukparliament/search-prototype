class SearchController < ApplicationController
  before_action :begin_timer

  def index
    @page_title = "Search results"
    @search_data = SearchData.new(SolrSearch.new(search_params).data)

    @type_facets = @search_data.type_facets
    @expanded_types = @search_data.expanded_types
    @hierarchy_data = @search_data.hierarchy_data

    @associated_object_data = @search_data.associated_object_data

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
                  :show_detailed, filter: {})
  end

  def permitted_filters
    # Not currently used

    hash = {}
    SolrSearch.facet_fields.each do |field|
      hash[field.to_sym] = []
    end

    hash
  end
end
