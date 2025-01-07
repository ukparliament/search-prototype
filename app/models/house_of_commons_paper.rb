class HouseOfCommonsPaper < ParliamentaryPaperLaid

  def initialize(content_object_data)
    super
  end

  def search_result_partial
    'search/results/house_of_commons_paper'
  end

  def search_result_ses_fields
    %w[type_ses subtype_ses department_ses corporateAuthor_ses
       legislationTitle_ses subject_ses legislature_ses]
  end
end