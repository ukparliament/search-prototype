class ContentObjectsController < ApplicationController

  def index

  end

  def show
    # We get the object URI passed as a parameter and pass to a new instance of ApiCall
    object_data = ApiCall.new(object_uri: params[:object]).object_data

    # We pass the received data to the object class
    @object = ContentObject.generate(object_data)

    # Temporarily passing object data to the template directly ahead of refactoring it
    render template: @object.template, :locals => { :object => object_data }
  end

end