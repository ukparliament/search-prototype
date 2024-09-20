module DateHelper

  def format_date(data)
    return unless data

    return if data[:value].blank?

    data[:value].to_date.strftime(ApplicationHelper::DATE_FORMAT_WITH_DAY)
  end

  def format_date_without_day(data)
    return unless data

    return if data[:value].blank?

    data[:value].to_date.strftime(ApplicationHelper::DATE_FORMAT_WITHOUT_DAY)
  end
end