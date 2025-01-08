class EuropeanDepositedDocument < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/european_deposited_document'
  end

  def search_result_partial
    'search/results/european_deposited_document'
  end

  def search_result_solr_fields
    # fields requested in Solr search for search results page
    %w[
    title_t uri
    department_ses department_t
    type_ses subtype_ses
    dateOriginated_dt
    dateDeposited_dt
    subject_ses subject_t
    date_dt identifier_t legislature_ses
    ]
  end

  def object_name
    subtype_or_type
  end

  def deposited_date
    get_first_as_date_from('dateDeposited_dt')
  end

  def commission_number
    get_first_from('commissionNumber_t')
  end

  def elc_number
    get_first_from('elcNumber_t')
  end

  def council_number
    get_first_from('councilNumber_t')
  end

  def other_number
    get_first_from('otherNumber_t')
  end

  def date_originated
    get_first_as_date_from('dateOriginated_dt')
  end

  def subsidiarity_from_date
    get_first_as_date_from('subsidiarityFromDate_dt')
  end

  def subsidiarity_to_date
    get_first_as_date_from('subsidiarityToDate_dt')
  end
end