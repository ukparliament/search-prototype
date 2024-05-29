class SessionFacet < Facet

  attr_reader :facet_data

  def initialize(facet_data)
    @facet_data = facet_data
  end

  def formatted
    # returns an object that looks like a Solr facet (probably - may change)

    # Paused for the time being - unsure if it's possible to reassemble these labels, may be that a different approach is needed
    # for now this is just returning what it got given, unchanged
    facet_data
  end
end
