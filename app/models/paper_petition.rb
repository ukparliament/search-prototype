class PaperPetition < Petition

  def initialize(content_type_object_data)
    super
  end

  def template
    'content_type_objects/object_pages/paper_petition'
  end

  def search_result_partial
    'search/results/paper_petition'
  end

  def self.search_result_solr_fields
    # fields requested in Solr search for search results page
    super << %w[
    petitionText_t
    abstract_t
    legislationTitle_ses
    legislationTitle_t
    subject_t
    searcherNote_t
    date_dt
    identifier_t
    legislature_ses
    ]
  end

  def object_name
    subtype
  end
end