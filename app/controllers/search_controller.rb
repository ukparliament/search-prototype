class SearchController < ApplicationController
  before_action :begin_timer

  def index
    @page_title = "Search results"
    @search_data = SearchData.new(SolrSearch.new(search_params).data)

    if @search_data.solr_error?
      render template: @search_data.error_partial_path, locals: { status: @search_data.error_code, message: @search_data.error_message }
    else
      @objects = @search_data.object_data[:items]

      # Type facet hierarchy
      @type_facets = @search_data.type_facets
      @expanded_types = @search_data.expanded_types
      @hierarchy_data = @search_data.hierarchy_data

      # Associated objects
      @associated_object_results = AssociatedObjectsForSearchResults.new(@objects).data
      @associated_object_data = @associated_object_results.dig(:object_data)

      # SES data
      query_ses = @objects.map { |o| o.content_object_data.select { |k| o.class.search_result_ses_fields.include?(k) }.values }
      @ses_ids = [@search_data.facet_ses_ids + @associated_object_results.dig(:ses_ids) + query_ses].flatten.uniq
      @ses_data = SesData.new(@search_data.hierarchy_ses_data, @ses_ids).combined_ses_data
    end
  end

  private

  def begin_timer
    @start_time = Time.now
  end

  def search_params
    params.permit(:commit, :query, :page, :results_per_page, :sort_by, :toggled_facets,
                  :show_detailed, expanded_types: [], filter: {})
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
