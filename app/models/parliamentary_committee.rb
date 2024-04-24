class ParliamentaryCommittee < ParliamentaryPaperReported

  def initialize(content_object_data)
    super
  end

  def search_result_partial
    'search/results/parliamentary_committee'
  end
end