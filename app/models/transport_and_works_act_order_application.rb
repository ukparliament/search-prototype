class TransportAndWorksActOrderApplication < ContentTypeObject

  def initialize(content_type_object_data)
    super
  end

  def self.search_result_solr_fields
    # fields requested in Solr search for search results page
    super << %w[
    abstract_t
    agent_ses
    agent_t
    applicant_ses
    applicant_t
    commonsLibraryLocation_t
    date_dt
    dateOfOrigin_dt
    identifier_t
    legislationTitle_ses
    legislationTitle_t
    legislature_ses
    lordsLibraryLocation_t
    searcherNote_t
    subject_ses
    subject_t
    title_t
    uri
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