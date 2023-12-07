class ContentObjectsController < ApplicationController

  def index
    # used as landing page during development
    @page_title = 'Examples'
  end

  def show
    # We get the object URI passed as a parameter and pass to a new instance of ApiCall
    object_data = SolrQuery.new(object_uri: params[:object]).object_data

    # TODO: handle other error types
    if object_data['statusCode'] == 500
      render template: 'content_objects/error', locals: { status: 500, message: object_data['message'] }
    else
      # We pass the received data to the object class
      @object = ContentObject.generate(object_data)
      @ses_data = @object.ses_data

      object_title = @object.page_title
      object_type_id = @object.subtype_or_type

      if object_title.blank? && !object_type_id.blank?
        @page_title = "Untitled #{@ses_data[object_type_id[:value].to_i]}"
      else
        @page_title = object_title
      end

      # Pass the object data to the template
      render template: @object.template, :locals => { :object => @object }
    end
  end
end