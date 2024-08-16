class UnprintedPaper < ParliamentaryPaperLaid

  def initialize(content_object_data)
    super
  end

  def reference
    get_all_from('reference_t')
  end

  def search_result_partial
    'search/results/unprinted_paper'
  end
end