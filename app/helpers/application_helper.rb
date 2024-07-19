module ApplicationHelper

  # For formatting search result counts
  include ActiveSupport::NumberHelper

  # ## We set the date display format.
  DATE_DISPLAY_FORMAT = '%A, %e %B %Y'

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

  def ses_field_name(field)
    # returns display name for a SES field, e.g. 'Content Type' for type_ses

    field_names = {
      type_ses: 'Type',
      type_sesrollup: 'Type',
      legislature_ses: 'House',
      session_t: 'Session',
      date_dt: 'Date',
      member_ses: 'Member',
      legislativeStage_ses: 'Legislative stage',
      department_ses: 'Department',
      subject_ses: 'Subject',
      topic_ses: 'Topic',
      party_ses: 'Party',
      subtype_ses: 'Content subtype',
      tablingMember_ses: 'Tabling member',
      answeringMember_ses: 'Answering member',
      askingMember_ses: 'Asking member',
      leadMember_ses: 'Lead member',
      legislationTitle_ses: 'Legislation',
    }

    field_names[field.to_sym]
  end

  def checked_field(filter_params, facet_field_name, text_field_name)
    return false if filter_params.blank?

    filter_params[facet_field_name]&.include?(text_field_name)
  end

  def remove_filter_url(params, filter_name, filter_value)
    params.except(:page).merge(filter: params[:filter].merge({ filter_name => params.dig(:filter, filter_name)&.excluding(filter_value) }))
  end

  def apply_filter_url(params, filter_name, filter_value)
    params.except(:page).merge(filter: params.dig(:filter).nil? ? { filter_name => [filter_value] } : params.dig(:filter).merge(filter_name => [filter_value, params.dig(:filter, filter_name)].compact.flatten))
  end
end