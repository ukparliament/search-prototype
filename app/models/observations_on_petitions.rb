class ObservationsOnPetitions < Petition

  def initialize(content_type_object_data)
    super
  end

  def template
    'content_type_objects/object_pages/observations_on_petitions'
  end

  def search_result_partial
    'search/results/observation_on_a_petition'
  end

  def self.search_result_solr_fields
    # fields requested in Solr search for search results page
    %w[
    title_t uri
    petitionText_t
    leadMember_ses
    department_ses department_t
    type_ses subtype_ses
    legislationTitle_ses legislationTitle_t
    subject_ses subject_t
    searcherNote_t
    commonsLibraryLocation_t
    date_dt identifier_t legislature_ses
    ]
  end

  def display_link
    external_link = fallback(external_location_uri, external_location_text)
    fallback(external_link, get_first_from('location_uri'))
  end

end