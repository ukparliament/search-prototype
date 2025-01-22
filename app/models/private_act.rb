class PrivateAct < Act

  def initialize(content_type_object_data)
    super
  end

  def template
    'content_type_objects/object_pages/private_act'
  end

  def search_result_partial
    'search/results/private_act'
  end

  def self.search_result_solr_fields
    # fields requested in Solr search for search results page
    %w[
    title_t uri
    legislationTitle_ses legislationTitle_t
    subject_ses subject_t
    searcherNote_t
    commonsLibraryLocation_t lordsLibraryLocation_t
    date_dt identifier_t legislature_ses
    ]
  end
end