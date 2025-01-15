class SearchController < ApplicationController
  before_action :begin_timer

  def index
    @page_title = "Search results"
    # TODO: this initial query is simple and could be cached - check
    @search_data = SearchData.new(SolrSearch.new(search_params).data)

    if @search_data.solr_error?
      render template: @search_data.error_partial_path, locals: { status: @search_data.error_code, message: @search_data.error_message }
    else
      # TODO: for the time being, filter filtering (via field list) is disabled pending a test of effectiveness
      @objects = @search_data.object_data[:items]

      # Type facet hierarchy
      @type_facets = @search_data.type_facets
      @expanded_types = @search_data.expanded_types
      @hierarchy_data = @search_data.hierarchy_data

      # Associated objects
      @associated_object_results = AssociatedObjects.new(@objects).data
      @associated_object_data = @associated_object_results.dig(:object_data)

      # Assemble SES IDs for minimal SES querying
      query_ses = @objects.map { |o| o.content_object_data.select { |k| o.search_result_ses_fields.include?(k) }.values }
      puts "#{query_ses.flatten.uniq.size} SES IDs from the requested objects" if Rails.env.development?
      associated_ses = @associated_object_results.dig(:ses_ids)
      puts "#{associated_ses.flatten.uniq.size} SES IDs from associated objects" if Rails.env.development?
      facet_ses = @search_data.facet_ses_ids
      puts "#{facet_ses.flatten.uniq.size} SES IDs from facets" if Rails.env.development?
      @ses_ids = [facet_ses + associated_ses + query_ses].flatten.uniq
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
