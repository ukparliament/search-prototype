class ObservationsOnPetitions < Petition

  def initialize(content_type_object_data)
    super
  end

  def self.associated_objects
    # fields requested in Solr search for search results page
    %w[
    askedToReplyAuthor_ses
    commonsLibraryLocation_t
    date_dt
    department_ses
    department_t
    identifier_t
    leadMember_ses
    leadMemberParty_ses
    legislationTitle_ses
    legislationTitle_t
    legislature_ses
    petitionText_t
    searcherNote_t
    ]
  end

  def display_link
    external_link = fallback(external_location_uri, external_location_text)
    fallback(external_link, get_first_from('location_uri'))
  end

end