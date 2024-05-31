module FacetHelper

  def format_facets(facet_data)
    # accepts a SES facet param for a single facet and processes it depending on the field name

    case facet_data[:field_name]
    when 'session_t'
      facet_object = SessionFacet.new(facet_data)
    else
      # if we don't have a special case for this facet, just return the data unprocessed
      return facet_data
    end

    facet_object.formatted
  end
end
