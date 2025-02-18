module ApplicationHelper

  # For formatting search result counts
  include ActiveSupport::NumberHelper

  # ## We set the date display format.
  DATE_FORMAT_WITH_DAY = '%A, %e %B %Y'
  DATE_FORMAT_WITHOUT_DAY = '%e %B %Y'

  def format_html(html, truncate_words)
    if truncate_words == false
      Nokogiri::HTML::DocumentFragment.parse(html).to_html
    else
      Nokogiri::HTML::DocumentFragment.parse(html.truncate_words(truncate_words)).to_html
    end
  end

  def boolean_yes_no(boolean)
    # outputs 'Yes' or 'No' strings from a boolean (an instance of Ruby TrueClass or FalseClass)
    # for presenting output of methods such as WrittenQuestion transferred?
    # Note that in most cases the partial will not be rendered except where the answer is 'Yes', but exceptions exist
    return 'Yes' if boolean && boolean[:value] == true

    'No'
  end

  def ordinal_text(index)
    case index
    when 0
      "first"
    when 1
      "second"
    when 2
      "third"
    when 3
      "fourth"
    when 4
      "fifth"
    when 5
      "sixth"
    when 6
      "seventh"
    when 7
      "eighth"
    when 8
      "ninth"
    else
      (index + 1).ordinalize
    end
  end

  def format_object_title(object_title, ses_data)
    return "Untitled" if object_title.blank?

    # object title is either a string: "Title"
    return object_title if object_title.is_a?(String)

    # or it's a SES ID and accompanying field name: {:value=>91910, :field_name=>"subtype_ses"}
    if object_title.is_a?(Hash)
      return "Untitled" if object_title.dig(:value).blank?

      ses_id = object_title.dig(:value)
      type = ses_data.dig(ses_id)&.singularize

      return type.blank? ? "Untitled" : "Untitled #{type}"
    end

    # in development, raise an error if we have any other data type
    raise "Unknown object title" if Rails.env.development?

    # or return "Untitled" in production
    "Untitled"
  end

  def filter_field_name(field)
    # Returns display name for a filter field.

    # Filter name entries will be needed for all fields that come under each heading, e.g.
    # legislationTitle_ses and legislationTitle_t are both shown under 'Legislation' and both
    # need to be included here with that label.

    field_names = {
      type_sesrollup: 'Type',
      type_ses: 'Type',
      subtype_ses: 'Subtype',
      legislature_ses: 'House',
      date_dt: 'Date',
      session_t: 'Session',
      department_ses: 'Department',
      department_t: 'Department',
      answeringDepartment_ses: 'Department',
      member_ses: 'Member',
      primaryMember_ses: 'Primary member',
      askingMember_ses: 'Primary member',
      leadMember_ses: 'Primary member',
      primarySponsor_ses: 'Primary member',
      tablingMember_ses: 'Primary member',
      answeringMember_ses: 'Answering member',
      legislativeStage_ses: 'Legislative stage',
      legislationTitle_ses: 'Legislation',
      legislationTitle_t: 'Legislation',
      subject_ses: 'Subject',
      subject_t: 'Subject',
      publisher_ses: 'Publisher'
    }

    raise "Unknown field name '#{field}'" if Rails.env.development? && !field_names.keys.include?(field.to_sym)

    field_names[field.to_sym]
  end

  def filter_field_value(filter, filter_value)
    return filter_value unless filter.first == "month"

    split = filter_value.split("-")
    year = split.first
    month = split.last

    month_string = Date::MONTHNAMES[month.to_i]
    "#{month_string} #{year}"
  end

  def checked_field(filter_params, facet_field_name, text_field_name)
    return false if filter_params.blank?

    filter_params[facet_field_name]&.include?(text_field_name)
  end

  def remove_filter_url(params, filter_name, filter_value)
    params.except(:page).merge(filter: params[:filter].merge({ filter_name => params.dig(:filter, filter_name)&.excluding(filter_value) }))
  end

  def apply_filter_url(params, filter_name, filter_value)
    # example output:
    # {"query"=>"horses", "commit"=>"Search", "controller"=>"search", "action"=>"index", "filter"=>{"type_sesrollup"=>[90996]}}
    params.except(:page).merge(filter: params.dig(:filter).nil? ? { filter_name => [filter_value] } : params.dig(:filter).merge(filter_name => [filter_value, params.dig(:filter, filter_name)].compact.flatten))
  end

  def replace_filter_url(params, filter_name, filter_value)
    # used for year-month filters; performs the additional step of removing year filters first
    adjusted_params = params.except(:filter, :year)
    apply_filter_url(adjusted_params, filter_name, filter_value)
  end

  def year_filter
    params.dig(:filter, :year)
  end
end