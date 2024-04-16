# # The one and only search controller.
class SearchController < ApplicationController

  def index
    # TODO: refactor overstuffed controller action

    @page_title = "Search results"
    @search = SolrSearch.new(search_params)
    @all_data = @search.all_data
    @response = @all_data['response']

    @all_facets = @all_data['facet_counts']['facet_fields'].map do |facet_field|
      { field_name: facet_field.first, facets: Hash[*facet_field.last] }
    end

    if @response.has_key?('code')
      if [401, 404].include?(@response['code'])
        render template: "layouts/shared/error/#{@response['code']}", locals: { status: @response['code'], message: @response['msg'] }
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

      ses_ids = data.pluck('all_ses').flatten
      facet_ses = @all_data['facet_counts']['facet_fields'].select { |k, v| k.last(3) == "ses" }.flat_map { |k, v| Hash[*v].keys.map(&:to_i) }
      combined_ses_ids = facet_ses + ses_ids
      unique_ses_ids = { value: combined_ses_ids.uniq }
      @ses_data = SesLookup.new([unique_ses_ids]).data unless unique_ses_ids.blank?
    end
  end

  private

  def search_params
    params.permit(:commit, :query, :page, :number_of_results, :sort_by, filter: [permitted_filters])
  end

  def permitted_filters
    hash = {}
    SolrSearch.facet_fields.each do |field|
      hash[field.to_sym] = []
    end

    hash
  end
end
