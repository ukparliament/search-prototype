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