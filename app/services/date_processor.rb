class DateProcessor

  attr_reader :search_term

  SUPPORTED_DATE_SHORTHANDS = ['today', 'yesterday', 'thisweek', 'this week', 'lastweek', 'last week', 'thismonth',
                               'this month', 'lastmonth', 'last month', 'thisyear', 'this year', 'lastyear',
                               'last year']

  TIMEZONE = ActiveSupport::TimeZone["Europe/London"]

  def initialize(search_term)
    @search_term = search_term
  end

  ##
  # Method to interpret search terms provided against a date field
  # Detects shorthand strings (e.g. 'today'), or interprets as a date string (e.g. '20/09/2022')
  def generate_date_string
    SUPPORTED_DATE_SHORTHANDS.include?(search_term) ? parse_shorthand : parse_date
  end

  private

  ##
  # evaluates provided shorthand date
  # returns a formated Solr date range
  def parse_shorthand
    case search_term
    when "today"
      start_date = Date.today
      range_start = local_time(start_date.year, start_date.month, start_date.day)
      range_end = range_start.end_of_day

    when "yesterday"
      start_date = Date.yesterday
      range_start = local_time(start_date.year, start_date.month, start_date.day)
      range_end = range_start.end_of_day

    when "thisweek", "this week"
      start_date = Date.today.beginning_of_week
      range_start = local_time(start_date.year, start_date.month, start_date.day)
      range_end = range_start.end_of_week

    when "lastweek", "last week"
      start_date = Date.today.last_week.beginning_of_week
      range_start = local_time(start_date.year, start_date.month, start_date.day)
      range_end = range_start.end_of_week

    when "thismonth", "this month"
      start_date = Date.today.beginning_of_month
      range_start = local_time(start_date.year, start_date.month, start_date.day)
      range_end = range_start.end_of_month

    when "lastmonth", "last month"
      start_date = Date.today.last_month.beginning_of_month
      range_start = local_time(start_date.year, start_date.month, start_date.day)
      range_end = range_start.end_of_month

    when "thisyear", "this year"
      start_date = Date.today.beginning_of_year
      range_start = local_time(start_date.year, start_date.month, start_date.day)
      range_end = range_start.end_of_year

    when "lastyear", "last year"
      start_date = Date.today.last_year.beginning_of_year
      range_start = local_time(start_date.year, start_date.month, start_date.day)
      range_end = range_start.end_of_year

    else
      # Raise an error if a supposedly supported shorthand doesn't have any supporting logic here
      raise QueryExpansionError
    end

    format_as_solr_date_range(range_start, range_end)
  end

  ##
  # Accepts a date string
  # Can be a range using ".." or " TO " as the separator
  # Also works with single dates, however this will return the string unaltered unless day_as_range is true, in
  # which a range is constructed representing the entire day
  def parse_date
    if search_term.split("..").size > 1
      # the user provided a date range using ".."
      # TODO: potentially support partial dates in ranges, e.g. 2022 TO 2025?
      range_start = search_term.split("..").first == "*" ? "*" : interpret_as_local_time(search_term.split("..").first)
      range_end = search_term.split("..").last == "*" ? "*" : interpret_as_local_time(search_term.split("..").last).end_of_day

    elsif search_term.split(" TO ").size > 1
      # the user provided a date range using " TO "
      range_start = search_term.split(" TO ").first == "*" ? "*" : interpret_as_local_time(search_term.split(" TO ").first)
      range_end = search_term.split(" TO ").last == "*" ? "*" : interpret_as_local_time(search_term.split(" TO ").last).end_of_day

    else
      # the user has provided a single date, which could be:
      # A day --> Range should represent the full day
      # A month --> Range should represent the full month
      # A year --> Range should represent the full year

      case search_term
      when /\A\d{2}[\/-]\d{4}\z/
        # 07/2026 or 07-2026 (entire month)
        month, year = search_term.split(/[\/-]/).map(&:to_i)
        range_start = local_time(year, month, 1)
        range_end = range_start.end_of_month
      when /\A\d{4}[\/-]\d{2}\z/
        # 2026/07 or 2026-07 (entire month)
        year, month = search_term.split(/[\/-]/).map(&:to_i)
        range_start = local_time(year, month, 1)
        range_end = range_start.end_of_month
      when /\A\d{2}[\/-]\d{2}\z/
        # 26/07 or 26-07 (entire month)
        year, month = search_term.split(/[\/-]/).map(&:to_i)
        range_start = local_time(year, month, 1)
        range_end = range_start.end_of_month
      when /\A\d{4}\z/
        # 2026 (specific year)
        year = search_term.to_i
        range_start = local_time(year, 1, 1)
        range_end = range_start.end_of_year
      when "*"
        # Don't process the wildcard character at all
        range_start = search_term
        range_end = search_term
      else
        # Formats representing a single day we leave to the regular Date parser
        date = Date.parse(search_term)
        range_start = local_time(date.year, date.month, date.day)
        range_end = range_start.end_of_day
      end
    end

    # pass to date range formatter
    format_as_solr_date_range(range_start, range_end)
  end

  # Parse a provided string as a date and generate a local time from it
  # An offset can be provided (e.g. for use with exclusive end ranges)
  def interpret_as_local_time(string)
    date = Date.parse(string)

    local_time(date.year, date.month, date.day)
  end

  def local_time(year, month, day)
    TIMEZONE.local(year, month, day)
  end

  ##
  # Method to generate a date range string for Solr queries
  # Allows for inclusive or exclusive start/end
  # Must be given a Ruby Time for start/end dates
  # Solr times are recorded in the London time zone but expressed as UTC, so we convert to UTC here
  def format_as_solr_date_range(start_date, end_date)
    raise "Start date must be a Time or * (given #{start_date.class.name})" unless start_date.is_a?(Time) || start_date == "*"
    raise "End date must be a Time or * (given #{end_date.class.name})" unless end_date.is_a?(Time) || end_date == "*"

    formatted_start_date = start_date.is_a?(Time) ? start_date.utc.iso8601(3) : start_date
    formatted_end_date = end_date.is_a?(Time) ? end_date.utc.iso8601(3) : end_date

    "[#{formatted_start_date} TO #{formatted_end_date}]"
  end
end