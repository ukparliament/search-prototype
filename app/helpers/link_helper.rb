module LinkHelper
  SEARCH_LINK_FIELD_NAMES = %w[
    answeringDept_ses
    answeringMember_ses
    askingMember_ses
    department_ses
    leadMember_ses
    legislationTitle_ses
    legislationTitle_t
    legislativeStage_ses
    legislature_ses
    member_ses
    primarySponsor_ses
    publisher_ses
    subject_ses
    subject_t
    subtype_ses
    tablingMember_ses
    type_ses]

  def object_show_link(string, uri)
    # used where we have the title of an object and the link to that object in a source system
    # returns a titled link to the object show page for that url

    return if string.blank? || uri.blank?

    link_to(string, object_show_url(object: uri[:value]))
  end

  def search_link(data, singular: false, reading_order: true, html_class: nil)
    # TODO: not singularising correctly?
    # Accepts either a string or a SES ID, which it resolves into a string
    # Either option requires a field reference

    return if data.blank? || data[:value].blank?

    formatted_name = formatted_name(data, ses_data, singular, reading_order)
    return formatted_name unless SEARCH_LINK_FIELD_NAMES.include?(data[:field_name])

    field = substitute_field_name(data[:field_name])

    # format a search query for the link
    query = format_field_specific_search_query(field, formatted_name)

    link_to(formatted_name(data, ses_data, singular, reading_order), search_path(query: query), class: html_class || nil)
  end

  def substitute_field_name(field_name)
    # Click-through search links (from object page to a new search query) will submit the same field as that used
    # on the object page. We can override this here to instead use appropriate search aliases.
    # example format:
    # return 'type_sesrollup' if ['subtype_ses', 'type_ses'].include?(field_name)

    return 'answeredby' if ['answeringDept_ses', 'answeringMember_ses'].include?(field_name)
    return 'askedby' if ['askingMember_ses'].include?(field_name)
    return 'dept' if ['department_ses'].include?(field_name)
    return 'primarymember' if ['leadMember_ses'].include?(field_name)
    return 'legtitle' if ['legislationTitle_ses', 'legislationTitle_t'].include?(field_name)
    return 'legstage' if ['legislativeStage_ses'].include?(field_name)
    return 'house' if ['legislature_ses'].include?(field_name)
    return 'member' if ['member_ses'].include?(field_name)
    return 'primarysponsor' if ['primarySponsor_ses'].include?(field_name)
    return 'publisher' if ['publisher_ses'].include?(field_name)
    return 'subject' if ['subject_ses', 'subject_t'].include?(field_name)
    return 'type' if ['subtype_ses', 'type_ses'].include?(field_name)
    return 'tabledby' if ['tablingMember_ses'].include?(field_name)

    field_name
  end

  def scope_note(ses_id_string)
    # look up scope note in SES data based on string
    # string format is '12345_scope_note'

    return if ses_id_string.blank?

    @ses_data.dig(ses_id_string)
  end

  def object_display_name(data, singular: true, case_formatting: false, reading_order: true)
    # Formats the name of an object for display; does not return a link. Works with string names or SES
    # IDs (for dynamic objects).
    #
    # Singular: If true, result is singularised
    # Case formatting: If true, result is lowercase, except for some whitelisted phrases e.g. "House of Commons"
    # Reading order: If true, result is flipped on internal comma, e.g. "Sharpe of Epsom, Lord" -> "Lord Sharpe of Epsom"

    return if data.blank? || data[:value].blank?

    formatted = formatted_name(data, ses_data, singular, reading_order)

    if case_formatting
      conditional_downcase(formatted)
    else
      formatted
    end
  end

  def format_field_specific_search_query(field, value)
    # given a Solr field name & a value, returns a formatted search string suitable for building search links
    raise 'Value is not a string' unless value.is_a?(String)

    # Return field:string or field:"a phrase"
    value.to_s.include?(" ") ? "#{field}:\"#{value}\"" : "#{field}:#{value}"
  end

  def object_display_name_link(data, singular: true, case_formatting: false, reading_order: true)
    # Formats the name of an object for display; returns as a link to search for that object.
    # Singular: If true, result is singularised
    # Case formatting: If true, result is lowercase, except for some whitelisted phrases e.g. "House of Commons"
    # Reading order: If true, result is flipped on internal comma, e.g. "Sharpe of Epsom, Lord" -> "Lord Sharpe of Epsom"
    return if data.blank? || data[:value].blank?

    field = substitute_field_name(data[:field_name])
    formatted = formatted_name(data, ses_data, singular, reading_order)
    query = format_field_specific_search_query(field, formatted)

    link_to(case_formatting ? conditional_downcase(formatted) : formatted, search_path(query: query))
  end

  def formatted_name(data, ses_data, singular, reading_order)
    formatted = format_name(data, ses_data, reading_order)

    singular ? singularize_phrase(formatted) : formatted
  end

  private

  def format_name(data, ses_data, reading_order)
    # This method processes names, handling commas and disambiguation
    # It accepts a standard data hash with a SES ID or string

    return if data.blank?

    if data[:field_name] && ["ses", "sesrollup"].include?(data[:field_name]&.split('_')&.last)
      # if data[:field_name]&.last(3) == 'ses'
      # we need to get the string from the page SES data
      raise "No SES data available to dereference SES ID" unless ses_data
      name_string = ses_data.dig(data[:value].to_i)

      if name_string.nil?
        puts "Missing SES name for ID #{data[:value]}" if Rails.env.development?
        name_string = fallback_ses_lookup(data)
      end
    elsif data[:field_name] && data[:field_name] == 'date_month'
      # month numbers need to be converted to names
      name_string = Date::MONTHNAMES[data[:value].to_i]
    else
      # we already have a string
      name_string = data[:value].to_s
    end

    return if name_string.blank?

    return name_string unless human_name_fields.include?(data[:field_name]) && name_string.include?(',') && reading_order

    if name_string.include?('(')
      # handle disambiguation brackets
      disambiguation_components = name_string.split(' (')
      # 'Sharpe of Epsom, Lord (Disambiguation)' => ['Sharpe of Epsom, Lord', 'Disambiguation)']

      name_components = disambiguation_components.first.split(',')
      # ['Sharpe of Epsom', 'Lord']

      # we return as 'Lord Sharpe of Epsom (Disambiguation)'
      ret = "#{name_components.last} #{name_components.first} (#{disambiguation_components.last}"
    else
      # we get something like 'Sharpe of Epsom, Lord'
      name_components = name_string.split(',')
      # we return as 'Lord Sharpe of Epsom'
      ret = "#{name_components.last} #{name_components.first}"
    end

    ret.strip
  end

  def ses_data
    @ses_data
  end

  def conditional_downcase(name)
    # converts name to lowercase, then iterates through exceptions list to capitalise certain words/phrases
    downcased = name.downcase
    downcase_exceptions.each do |lower_case, upper_case|
      downcased.gsub!(lower_case, upper_case)
    end

    downcased
  end

  def downcase_exceptions
    # having downcased entire names, we can use this list to upcase words or phrases

    {
      'house of commons' => 'House of Commons',
      'house of lords' => 'House of Lords',
      'parliament' => 'Parliament',
      'parliamentary' => 'Parliamentary',
      'parliamentary committees' => 'Parliamentary Committees',
      'european' => 'European',
      'eu' => 'European',
      'european material produced by eu institutions' => 'European material produced by EU institutions',
      'transport and works act' => 'Transport and Works Act',
      'grand committee' => 'Grand Committee',
      'church of england' => 'Church of England'
    }

  end

  def human_name_fields
    # only for member's names containing a comma (?), optionally with disambiguation brackets

    [
      'amendment_primarySponsorPrinted_t',
      'amendment_primarySponsor_ses',
      'answeringMember_ses',
      'askingMember_ses',
      'contributor_ses',
      'contributor_t',
      'correctingMember_ses',
      'correspondingMinister_t',
      'correspondingMinister_ses',
      'creator_ses',
      'creator_t',
      'leadMember_ses',
      'member_ses',
      'memberPrinted_t',
      'mep_ses',
      'personalAuthor_ses',
      'personalAuthor_t',
      'primarySponsor_ses',
      'signedMember_ses',
      'sponsor_ses',
      'tablingMember_ses',
      'witness_ses',
      'witness_t'
    ]
  end

  def fallback_ses_lookup(ses_data_hash)
    # an inefficient method that a SES name for a single ID, used as a last resort if names are still missing when
    # links / names are being formatted.

    # raise an error in development instead
    # raise 'fallback SES lookup attempted' if Rails.env.development?

    custom_ses_lookup = SesLookup.new([ses_data_hash]).data
    name_string = custom_ses_lookup[ses_data_hash[:value].to_i]

    # where we still don't have a string (e.g. if SES is missing an entry for this ID) then
    # present the SES ID itself as a string (in development), or "Unknown" in other environments.

    return name_string unless name_string.blank?

    Rails.env.development? ? ses_data_hash[:value].to_s : "Unknown"
  end

end