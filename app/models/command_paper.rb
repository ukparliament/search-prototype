class CommandPaper < ParliamentaryPaperLaid

  def initialize(content_object_data)
    super
  end

  def search_result_partial
    'search/results/command_paper'
  end
end