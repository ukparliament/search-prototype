module DateHelper

  def format_date(data)
    return unless data

    return if data[:value].blank?

    data[:value].to_date.strftime(ApplicationHelper::DATE_DISPLAY_FORMAT)
  end
end