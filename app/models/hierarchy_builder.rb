class HierarchyBuilder

  attr_reader :ses_data, :facet_data

  def initialize(facet_ids)
    @ses_data = get_data_from_ses(facet_ids)
    @facet_data = facet_ids.map(&:to_i)
  end

  def get_data_from_ses(root_id = 346696)
    SesLookup.new([{ value: root_id }]).extract_hierarchy_data
  end

  def hierarchy_data
    organise_hierarchy_data(ses_data)
  end

  def organise_hierarchy_data(ses_data)
    ret = {}

    return unless ses_data.is_a?(Hash)

    ses_data.each do |k, v|
      narrower_term_hash = v.select { |h| h["abbr"] == "NT" }.first
      array = []
      children = narrower_term_hash&.dig("fields")

      unless children.nil?
        children.each do |child|
          child_values = {}
          child_values[:id] = child.dig('field', 'id')&.to_i
          child_values[:name] = child.dig('field', 'name')
          array << child_values
        end
      end

      ret[k.first] = { name: k.last, children: array }
    end

    ret
  end

  def top_level_types
    return unless ses_data.is_a?(Hash)

    ret = []
    # select types that have 'Content Type' as their parent
    ses_data.select { |k, v| v.first.dig("fields").first.dig("field", "id") == "346696" }.keys.map do |id, name|
      ret << { id: id, name: name }
    end

    ret
  end
end
