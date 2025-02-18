module LinkHelper
  def object_show_link(string, uri)
    # used where we have the title of an object and the link to that object in a source system
    # returns a titled link to the object show page for that url

    return if string.blank? || uri.blank?

    link_to(string, object_show_url(object: uri[:value]))
  end

  def search_link(data, singular: false, reading_order: true)
    # Accepts either a string or a SES ID, which it resolves into a string
    # Either option requires a field reference (standard data hash)

    return if data.blank? || data[:value].blank?

    search_link_field_names = %w[
    answeringDept_ses
    answeringMember_ses
    askingMember_ses
    department_ses
    department_t
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

    formatted_name = formatted_name(data, ses_data, singular, reading_order)
    return formatted_name unless search_link_field_names.include?(data[:field_name])

    searchable_field_name = substitute_field_name(data[:field_name])
    value = data[:value]

    link_to(formatted_name(data, ses_data, singular, reading_order), search_path(filter: { searchable_field_name => [value] }))
  end

  def substitute_field_name(field_name)
    # Click-through search links (from object page to a new filtered search) will submit the same
    # field as that used on the object page. We can override this here, but because most facets are
    # shown as independent counts grouped under common headings, it isn't necessary.
    # Type is a special case: we use type_sesrollup to build the hierarchy so we're swapping out to
    # that field here.
    return 'type_sesrollup' if ['subtype_ses', 'type_ses'].include?(field_name)

    field_name
  end

  def scope_note(ses_id_string)
    # look up scope note in SES data based on string
    # string format is '12345_scope_note'

    return if ses_id_string.blank?

    @ses_data.dig(ses_id_string)
  end

  def object_display_name(data, singular: true, case_formatting: false, reading_order: true)
    # can used where the object type is dynamic by passing a SES ID
    # alternatively works with string names
    # e.g. secondary information title
    # does not return a link

    return if data.blank? || data[:value].blank?

    formatted = formatted_name(data, ses_data, singular, reading_order)

    if case_formatting
      conditional_downcase(formatted)
    else
      formatted
    end
  end

  def object_display_name_link(data, singular: true, case_formatting: false, reading_order: true)
    return if data.blank? || data[:value].blank?

    formatted = formatted_name(data, ses_data, singular, reading_order)
    field_name = substitute_field_name(data[:field_name])
    value = data[:value]

    if case_formatting
      link_to(conditional_downcase(formatted), search_path(filter: { field_name => [value] }))
    else
      link_to(formatted, search_path(filter: { field_name => [value] }))
    end
  end

  def formatted_name(data, ses_data, singular, reading_order)
    singular ? format_name(data, ses_data, reading_order)&.singularize : format_name(data, ses_data, reading_order)
  end

  private

  def format_name(data, ses_data, reading_order)
    # This method processes names, handling commas and disambiguation
    # It accepts a standard data hash with a SES ID or string

    return if data.blank?

    if data[:field_name] && ["ses", "sesrollup"].include?(data[:field_name]&.split('_')&.last)
      # if data[:field_name]&.last(3) == 'ses'
      # we need to get the string from the page SES data
      name_string = ses_data[data[:value].to_i]

      if name_string.nil?
        puts "Missing SES name for ID #{data[:value]}" if Rails.env.development?
        name_string = fallback_ses_lookup(data)
      end
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

  private

  def conditional_downcase(name)
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

    custom_ses_lookup = SesLookup.new([ses_data_hash]).data
    name_string = custom_ses_lookup[ses_data_hash[:value].to_i]

    # where we still don't have a string (e.g. if SES is missing an entry for this ID) then
    # present the SES ID itself as a string (in development), or "Unknown" in other environments.

    return name_string unless name_string.blank?

    Rails.env.development? ? ses_data_hash[:value].to_s : "Unknown"
  end

end