module LinkHelper
  def object_show_link(data, object_uri, anchor = nil)
    # this is a link directly to an object, e.g. where we already have a functional URL
    # this does not generate a search link
    # takes a standard data hash (so either a string or a SES ID)
    # performs its own SES lookup by necessity

    return if data.blank? || data[:value].blank?

    if data[:field_name].last(3) == 'ses'
      ses_data = SesLookup.new([data]).data
      link_text = ses_data[data[:value].to_i]
    else
      link_text = display_name(data[:value])
    end

    link_to(link_text&.singularize&.downcase, object_show_url(object: object_uri, anchor: anchor))
  end

  def search_link(data)
    # Accepts either a string or a SES ID, which it resolves into a string
    # Either option requires a field reference (standard data hash)

    return if data.blank? || data[:value].blank?

    if data[:field_name].last(3) == 'ses'
      link_text = ses_data[data[:value].to_i]
      link_to(display_name(link_text), search_path(filter: data))
    else
      query = data[:value]
      link_to(display_name(query), search_path(query: query))
    end

  end

  def object_display_name(data, singular = true, lowercase = true)

    # can used where the object type is dynamic by passing a SES ID
    # alternatively works with string names
    # uses standard data hash
    # e.g. secondary information title
    # does not return a link

    return if data.blank? || data[:value].blank?

    val = data[:value]

    if data[:field_name].last(3) == 'ses'
      text = display_name(ses_data[val.to_i])
    else
      text = display_name(val)
    end

    if singular && lowercase
      text&.singularize&.downcase
    elsif singular
      text&.singularize
    elsif lowercase
      text&.downcase
    else
      text
    end

  end

  def object_display_name_link(data)
    # used where the object type is dynamic
    # accepts a standard data hash containing a SES ID
    # very similar to a search link, but the link text is singularised etc. to make it suitable
    # for use with object names
    return if data.blank? || data[:value].blank?

    if data[:field_name].last(3) == 'ses'
      link_text = ses_data[data[:value].to_i]
    else
      link_text = display_name(data[:value])
    end

    link_to(link_text&.singularize&.downcase, search_path(filter: data))
  end

  def display_name(ses_name)
    return if ses_name.blank?

    # only for names containing a comma (?)
    return ses_name unless ses_name.include?(',')

    if ses_name.include?('(')
      # handle disambiguation brackets

      disambiguation_components = ses_name.split(' (')
      # 'Sharpe of Epsom, Lord (Disambiguation)' => ['Sharpe of Epsom, Lord', 'Disambiguation)']

      name_components = disambiguation_components.first.split(',')
      # ['Sharpe of Epsom', 'Lord']

      # we return as 'Lord Sharpe of Epsom (Disambiguation)'
      ret = "#{name_components.last} #{name_components.first} (#{disambiguation_components.last}"
    else
      # we get something like 'Sharpe of Epsom, Lord'
      name_components = ses_name.split(',')

      # we return as 'Lord Sharpe of Epsom'
      ret = "#{name_components.last} #{name_components.first}"
    end
    ret.strip
  end

  private

  def ses_data
    @ses_data
  end

end