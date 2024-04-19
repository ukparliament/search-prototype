class ObservationsOnPetitions < Petition

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/observations_on_petitions'
  end

  def search_result_partial
    'search/results/observation_on_a_petition'
  end

  def display_link
    external_link = fallback(external_location_uri, external_location_text)
    fallback(external_link, get_first_from('location_uri'))
  end

end