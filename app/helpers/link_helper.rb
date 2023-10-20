module LinkHelper

  def object_link(link_text, object_uri, anchor=nil)
    # not sure what these links are supposed to be doing yet?
    link_to(link_text, object_show_url(object: object_uri, anchor: anchor))
  end

  def ses_object_link(ses_id)
    # these links will take the user to a new search prefiltered by the ses_id

    link_to(@ses_data[ses_id.to_i], '/')
  end

end