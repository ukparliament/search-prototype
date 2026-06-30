class SearchController < ApplicationController
  before_action :begin_timer

  def index
    @page_title = "Search Results"
    @description = "Results in Parliamentary Search for the query #{search_params[:query]}." unless search_params[:query].blank?

    # prevent searching without a query
    return redirect_back(fallback_location: home_path) if search_params[:query].blank?

    search = SolrSearch.new(**search_params.to_h.symbolize_keys)
    @search_data = SearchData.new(search.data)

    # filter out unsupported objects - may move this elsewhere
    @objects = @search_data.object_data.reject { |o| o.is_a?(NotSupported) }

    unless @objects.blank?
      # Type facet hierarchy
      @type_facets = @search_data.type_facets
      @expanded_types = @search_data.expanded_types
      @hierarchy_data = @search_data.hierarchy_data

      # Associated objects
      @associated_object_results = AssociatedObjectsForSearchResults.new(@objects).data
      @associated_object_data = @associated_object_results.dig(:object_data)

      # SES data
      # For each returned object, select from the Solr fields those that are listed by search_result_ses_fields for that object's class
      query_ses = @objects.map { |o| o.content_type_object_data.select { |k| o.class.search_result_ses_fields.include?(k) }.values }

      # The full list of SES IDs is obtained by combining:
      # - SES IDs for facets
      # - SES IDs for the results on the page
      # - SES IDs for associated objects of the results on the page
      ses_ids = [@search_data.facet_ses_ids + @associated_object_results.dig(:ses_ids) + query_ses].flatten.uniq
      @ses_data = SesData.new(ses_ids, @search_data.hierarchy_ses_data).combined_ses_data

      @crumb << { label: 'Search results', url: nil }
    end
  end

  private

  def begin_timer
    @start_time = Time.now
  end

  def search_params
    params.permit(:query,
                  :page,
                  :results_per_page,
                  :sort_by,
                  :show_detailed,
                  :expanded_types,
                  filter: {})
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
