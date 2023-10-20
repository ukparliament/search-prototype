class ContentObjectsController < ApplicationController

  def index
    # used as landing page during development
    @page_title = 'Examples'
  end

  def show
    # We get the object URI passed as a parameter and pass to a new instance of ApiCall
    object_data = ApiCall.new(object_uri: params[:object]).object_data

    # We pass the received data to the object class
    @object = ContentObject.generate(object_data)

    @page_title = @object.page_title
    @ses_data = @object.ses_data

    # Pass the object data to the template
    render template: @object.template, :locals => { :object => @object }
  end

end