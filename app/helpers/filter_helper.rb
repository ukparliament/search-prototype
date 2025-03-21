module FilterHelper
  def remove_filter_url(params, filter_name, filter_value)
    params.except(:page).merge(filter: params[:filter].merge({ filter_name => params.dig(:filter, filter_name)&.excluding(filter_value) }))
  end

  def apply_filter_url(params, filter_name, filter_value)
    # example output:
    # {"query"=>"horses", "commit"=>"Search", "controller"=>"search", "action"=>"index", "filter"=>{"type_sesrollup"=>[90996]}}
    params.except(:page).merge(filter: params.dig(:filter).nil? ? { filter_name => [filter_value] } : params.dig(:filter).merge(filter_name => [filter_value, params.dig(:filter, filter_name)].compact.flatten))
  end

  def replace_filter_url(params, filter_name, filter_value)
    # used for year-month filters; performs the additional step of removing year filters first
    adjusted_params = params.except(:filter, :year)
    apply_filter_url(adjusted_params, filter_name, filter_value)
  end

  def year_filter
    params.dig(:filter, :year)
  end
end