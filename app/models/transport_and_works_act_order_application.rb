class TransportAndWorksActOrderApplication < ContentTypeObject

  def initialize(content_type_object_data)
    super
  end

  def template
    'content_type_objects/object_pages/transport_and_works_act_order_application'
  end

  def search_result_partial
    'search/results/transport_and_works_act_order_application'
  end

  def self.search_result_solr_fields
    # fields requested in Solr search for search results page
    super << %w[
    title_t uri
    abstract_t
    applicant_ses applicant_t
    type_ses subtype_ses
    legislationTitle_ses legislationTitle_t
    subject_ses subject_t
    commonsLibraryLocation_t lordsLibraryLocation_t
    searcherNote_t
    date_dt identifier_t legislature_ses
    ]
  end

  def depositing_agent
    fallback(get_first_from('agent_ses'), get_first_from('agent_t'))
  end

  def depositing_applicant
    fallback(get_first_from('applicant_ses'), get_first_from('applicant_t'))
  end

  def date_originated
    get_first_as_date_from('dateOfOrigin_dt')
  end

  def display_link
    get_first_from('location_uri')
  end
end