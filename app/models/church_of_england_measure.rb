class ChurchOfEnglandMeasure < ContentTypeObject

  def initialize(content_type_object_data)
    super
  end

  def self.search_result_solr_fields
    # fields requested in Solr search for search results page
    super << %w[
      commonsLibraryLocation_t
      dateOfRoyalAssent_dt
      date_dt
      identifier_t
      legislationTitle_ses
      legislationTitle_t
      lordsLibraryLocation_t
      searcherNote_t
      subject_ses
      subject_t
      title_t
      uri
  ]
  end

  def date_of_royal_assent
    get_first_as_date_from('dateOfRoyalAssent_dt')
  end

  def display_link
    fallback(get_first_from('location_uri'), get_first_from('externalLocation_uri'))
  end
end