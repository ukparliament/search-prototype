class CommitteeProceeding < ParliamentaryProceeding

  def initialize(content_object_data)
    super
  end

  def search_result_partial
    'search/results/committee_proceeding'
  end
end