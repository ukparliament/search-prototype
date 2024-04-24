class GrandCommitteeProceeding < ParliamentaryProceeding

  def initialize(content_object_data)
    super
  end

  def search_result_partial
    'search/results/grand_committee_proceeding'
  end
end