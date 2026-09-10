module FacetHelper

  ##
  # Accepts a filter group and formats contained facts based on the filter name
  # Filter group is a hash: { name_string => [ <array of facet hashes, { :field_name, :count, :val}> ] }
  def format_filter_group(group_name, filter_group, matching_value: nil)
    case group_name
    when 'Month'
      # sort based on month number
      if matching_value
        # limit group to a provided value only - used to display only the selected month
        filter_group.sort_by { |h| h["val"] }.select { |f| f["val"].to_s == matching_value }
      else
        filter_group.sort_by { |h| h["val"] }
      end
    when 'Year', 'Session'
      # sort by value descending
      filter_group.sort_by { |h| h["val"] }.reverse
    else
      # if we don't have a special case for this group, just return the data unprocessed
      filter_group
    end
  end

  ##
  # For _s field facets, we need to swap the field name out for _t when applying the filter in order for the
  # search to work. We can't use _t to fetch the facet in the first place as this results in stemmed values shown
  # as filtering options.
  def replace_field_name(field_name)
    if field_name.last(2) == "_s"
      "#{field_name[0..-2]}t"
    else
      field_name
    end
  end
end
