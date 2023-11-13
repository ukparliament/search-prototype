module LinkHelper

  def object_link(link_text, object_uri, anchor = nil)
    # not sure what these links are supposed to be doing yet?
    link_to(link_text, object_show_url(object: object_uri, anchor: anchor))
  end

  def ses_object_link(ses_id)
    # these links will take the user to a new search prefiltered by the ses_id

    link_to(display_name(@ses_data[ses_id.to_i]), '/')
  end

  def ses_object_name_link(ses_id)
    # used where the object type is dynamic

    link_to(@ses_data[ses_id.to_i]&.singularize.downcase, '/')
  end

  def ses_object_name(ses_id)
    # used where the object type is dynamic but we don't actually want a link
    # e.g. secondary information title

    @ses_data[ses_id.to_i]&.singularize&.downcase
  end

  def ses_name(ses_id)
    # used where we want an as-is SES name but without a link
    # TODO: refactor into main helper method using optional parameter?
    display_name(@ses_data[ses_id.to_i])
  end

  def display_name(ses_name)
    return if ses_name.blank?

    # only for names containing a comma (?)
    return ses_name unless ses_name.include?(',')

    # we get something like 'Sharpe of Epsom, Lord'
    components = ses_name.split(',')

    # we return as 'Lord Sharpe of Epsom'
    "#{components.last} #{components.first}"
  end

end