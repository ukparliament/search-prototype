module HierarchyHelper
  def collapse(tier, expanded_types, parent_id)
    tier > 1 && !expanded_types.include?(parent_id.to_s) ? 'collapse' : ''
  end

  def has_children?(hierarchy_data, id, type_facets)
    return false unless hierarchy_data.dig(id, :children).any?

    children_in_results?(hierarchy_data, id, type_facets)
  end

  def toggle_symbol(expanded_types, id)
    if expanded_types.include?(id.to_s)
      '-'
    else
      '&#43;'
    end
  end

  def filter_applicable?(current_params, id)
    current_params.dig("filter", "type_sesrollup")&.include?(id.to_s) ? false : true
  end

  def name_and_count(hierarchy_data, id, type_facets)
    "#{hierarchy_data.dig(id, :name)} (#{ number_to_delimited(type_facets[id] || 0, separator: ",") })"
  end

  private

  def children_in_results?(hierarchy_data, id, type_facets)
    hierarchy_data.dig(id, :children).pluck(:id).select { |id| type_facets[id] }.any?
  end
end