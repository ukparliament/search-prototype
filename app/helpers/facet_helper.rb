module FacetHelper

  def format_facets(facet_data)
    # accepts a SES facet param for a single facet and processes it depending on the field name

    case facet_data[:field_name]
    when 'date_month'
      # sort based on month number
      sorted = facet_data[:facets].sort_by { |h| h["val"] }

      # replace original facet data with processed data & return the updated hash
      facet_data[:facets] = sorted
      facet_data
    when 'date_year'
      # sort by year descending
      sorted = facet_data[:facets].sort_by { |h| h["val"] }.reverse

      # replace original facet data with processed data & return the updated hash
      facet_data[:facets] = sorted
      facet_data
    else
      # if we don't have a special case for this facet, just return the data unprocessed
      return facet_data
    end
  end
end
