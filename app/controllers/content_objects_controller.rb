class ContentObjectsController < ApplicationController

  def index
    # used as landing page during development
    @page_title = 'Examples'
  end

  def show
    @response = SolrQuery.new(object_uri: params[:object]).all_data

    if @response['statusCode']
      case @response['statusCode']
      when 404
        render template: 'layouts/shared/error/404', locals: { status: @response['statusCode'], message: @response['message'] }
      when 500
        render template: 'layouts/shared/error/500', locals: { status: @response['statusCode'], message: @response['message'] }
      when 401
        render template: 'layouts/shared/error/401', locals: { status: @response['statusCode'], message: @response['message'] }
      else
        raise 'unknown error occurred'
      end

    else
      object_data = SolrQuery.new(object_uri: params[:object]).object_data
      @object = ContentObject.generate(object_data)
      @ses_data = @object.ses_data
      @page_title = @object.object_title

      render template: @object.template, :locals => { :object => @object }
    end

  end
end