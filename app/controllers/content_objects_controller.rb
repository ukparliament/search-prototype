class ContentObjectsController < ApplicationController

  def index
    # used as landing page during development
    @page_title = 'Examples'
  end

  def show
    object_data = SolrQuery.new(object_uri: params[:object]).object_data

    if object_data.blank?
      render template: 'content_objects/error', locals: { status: 404, message: 'Resource not found' }
    elsif [404, 403, 500].include?(object_data['statusCode'])
      render template: 'content_objects/error', locals: { status: object_data['statusCode'], message: object_data['message'] }
    else
      @object = ContentObject.generate(object_data)
      @ses_data = @object.ses_data
      @page_title = @object.object_title

      render template: @object.template, :locals => { :object => @object }
    end
  end
end