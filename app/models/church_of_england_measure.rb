class ChurchOfEnglandMeasure < ContentTypeObject

  def initialize(content_type_object_data)
    super
  end

  def self.search_result_solr_fields
    # fields requested in Solr search for search results page
    %w[title_t uri type_ses
      subtype_ses legislationTitle_ses
      legislationTitle_t subject_ses subject_t searcherNote_t
      commonsLibraryLocation_t lordsLibraryLocation_t date_dt identifier_t]
  end

  def date_of_royal_assent
    get_first_as_date_from('dateOfRoyalAssent_dt')
  end

  def template
    'content_type_objects/object_pages/church_of_england_measure'
  end

  def search_result_partial
    'search/results/church_of_england_measure'
  end

  def display_link
    fallback(get_first_from('location_uri'), get_first_from('externalLocation_uri'))
  end
end