module LinkHelper

  def object_link(link_text, object_uri, anchor=nil)
    # not sure what these links are supposed to be doing yet?
    link_to(link_text, object_show_url(object: object_uri, anchor: anchor))
  end

end