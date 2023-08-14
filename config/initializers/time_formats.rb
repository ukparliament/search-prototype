# Sunday, 15 June 2003.
Time::DATE_FORMATS[:day_date_month_year] = lambda { |time|
  time.strftime("%A, %e %B %Y")
}