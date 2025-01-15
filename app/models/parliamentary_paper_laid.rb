class ParliamentaryPaperLaid < Paper

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/parliamentary_paper_laid'
  end

  def search_result_partial
    'search/results/parliamentary_paper_laid'
  end

  def search_result_solr_fields
    # fields requested in Solr search for search results page
    %w[
    title_t uri
    memberPrinted_t
    department_ses department_t
    type_ses subtype_ses
    corporateAuthor_ses corporateAuthor_t
    procedure_t
    dateLaid_dt dateOfOrderToPrint_dt dateWithdrawn_dt
    legislationTitle_ses legislationTitle_t
    subject_ses subject_t
    searcherNote_t
    commonsLibraryLocation_t lordsLibraryLocation_t
    date_dt identifier_t legislature_ses
    ]
  end

  def object_name
    # type shown for most papers, except 92347 which uses subtypes (plural)
    return if type.blank?

    if type[:value] != 92347 || subtypes.blank?
      [type]
    else
      subtypes
    end
  end

  def is_withdrawn
    get_first_as_boolean_from('withdrawn_b')
  end

  def paper_type
    # show subtypes, except if type is 92347
    return if type[:value] == 92347

    super
  end

  def is_considered_by_eu_si_committee
    get_first_as_date_from('ConsideredByESICDate_dt')
  end

  def is_considered_by_secondary_legislation_committee
    get_first_as_date_from('ConsideredBySLSCDate_dt')
  end

  def display_link
    location_uri = get_first_from('location_uri')
    return location_uri unless location_uri.blank?

    location_t = get_first_from('location_t')
    external_location_t = get_first_from('externalLocation_t')
    fallback(location_t, external_location_t)
  end

  def dual_type?
    # used to show both type and subtype with equal importance in related items partial
    return false if type.blank? || subtype.blank?

    type[:value] == 91561 && subtype[:value] == 91563
  end
end