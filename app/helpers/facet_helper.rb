module FacetHelper

  ##
  # accepts a SES facet param for a single facet and processes it depending on the field name
  def format_facet(facet_data)
    case facet_data[:field_name]
    when 'date_month'
      # sort based on month number
      sorted = facet_data[:facets].sort_by { |h| h["val"] }

      # replace original facet data with processed data & return the updated hash
      facet_data[:facets] = sorted
      facet_data
    when 'date_year', 'session_s'
      # sort by value descending
      sorted = facet_data[:facets].sort_by { |h| h["val"] }.reverse

      # replace original facet data with processed data & return the updated hash
      facet_data[:facets] = sorted
      facet_data
    else
      # if we don't have a special case for this facet, just return the data unprocessed
      return facet_data
    end
  end

  ##
  # Accepts a filter group and formats contained facts based on the filter name
  # Filter group is a hash: { name_string => [ <array of facet hashes, { :field_name, :count, :val}> ] }
  def format_filter_group(group_name, filter_group)
    case group_name
    when 'Month'
      # sort based on month number
      sorted = filter_group.value.sort_by { |h| h["val"] }

      # replace original data with processed data & return the updated hash
      filter_group.value = sorted
      filter_group
    when 'Year', 'Session'
      # sort by value descending
      sorted = filter_group.value.sort_by { |h| h["val"] }.reverse

      # replace original data with processed data & return the updated hash
      filter_group.value = sorted
      filter_group
    else
      # if we don't have a special case for this group, just return the data unprocessed
      return filter_group
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
