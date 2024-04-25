class HouseOfCommonsPaper < ParliamentaryPaperLaid

  def initialize(content_object_data)
    super
  end

  def search_result_partial
    'search/results/house_of_commons_paper'
  end
end