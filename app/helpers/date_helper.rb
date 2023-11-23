module DateHelper

  def format_date(data)
    return if data[:value].blank?

    data[:value].strftime(ApplicationHelper::DATE_DISPLAY_FORMAT)
  end
end