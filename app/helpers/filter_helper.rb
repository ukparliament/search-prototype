module FilterHelper
  def remove_filter_url(params_hash, filter_name, filter_value)
    baseline_params = params_hash.except(:page)
    if %w[date_month date_year].include?(filter_name)
      # because date filtering is emulating a drilldown, we want the remove filter link to clear all month/year filters
      url_params = baseline_params.merge(filter: params_hash.dig(:filter).merge({ 'date_month' => [], 'date_year' => [] }))
    else
      other_values_for_current_filter = params_hash.dig(:filter, filter_name)&.excluding(filter_value)
      url_params = baseline_params.merge(filter: params_hash.dig(:filter).merge({ filter_name => other_values_for_current_filter }))
    end

    url_for(url_params)
  end

  def apply_filter_url(params, filter_name, filter_value)
    # example output:
    # {"query"=>"horses", "commit"=>"Search", "controller"=>"search", "action"=>"index", "filter"=>{"type_sesrollup"=>[90996]}}
    url_params = params.except(:page).merge(filter: params.dig(:filter).nil? ? { filter_name => [filter_value] } : params.dig(:filter).merge(filter_name => [filter_value, params.dig(:filter, filter_name)].compact.flatten))

    url_for(url_params)
  end

  def visible_filters
    params[:filter].has_key?('date_month') ? params[:filter].except('date_year') : params[:filter]
  end

  def applied_filters
    params[:filter]
  end

  def current_month_filter_value
    return unless applied_filters

    applied_filters.dig('date_month')&.first
  end
end