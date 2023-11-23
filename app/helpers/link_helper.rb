module LinkHelper

  def object_link(link_text, object_uri, anchor = nil)
    # not sure what these links are supposed to be doing yet?
    link_to(link_text, object_show_url(object: object_uri, anchor: anchor))
  end

  def ses_object_link(data)
    return if data.blank? || data[:value].blank?

    link_to(display_name(ses_data[data[:value].to_i]), search_path(filter: data))
  end

  def ses_object_name(ses_id)
    # used where the object type is dynamic but we don't actually want a link
    # e.g. secondary information title

    ses_data[ses_id.to_i]&.singularize&.downcase
  end

  def ses_object_name_link(ses_id)
    # used where the object type is dynamic
    # TODO: update this link to perform a search based on type_ses
    return if ses_id.blank?

    link_to(ses_data[ses_id.to_i]&.singularize&.downcase, '/')
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