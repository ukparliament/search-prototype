class ContentObjectsController < ApplicationController

  def index
    # used as landing page during development
    @page_title = 'Examples'
  end

  def show
    object_data = SolrQuery.new(object_uri: params[:object]).object_data

    # TODO: handle other error types
    if object_data['statusCode'] == 500
      render template: 'content_objects/error', locals: { status: 500, message: object_data['message'] }
    else
      @object = ContentObject.generate(object_data)
      @ses_data = @object.ses_data
      @page_title = @object.object_title

      render template: @object.template, :locals => { :object => @object }
    end
  end
end