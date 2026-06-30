class ContentTypeObjectsController < ApplicationController

  def show
    # Raise a 400 if we didn't get an object URL
    raise MissingParameterError, :id if params[:object].blank?

    # fetch object data
    object_data = SolrQuery.new(object_uri: params[:object]).object_data

    # construct the object
    @object = ContentTypeObject.generate(object_data)

    # raise a 404 if we didn't successfully generate an object
    raise ObjectNotFoundError, params[:object] unless @object

    # check the object is supported
    raise ObjectNotSupportedError, params[:object] if @object.is_a?(NotSupported)

    # fetch associated object data
    associated_object_results = AssociatedObjectsForObjectView.new(@object).data
    @associated_object_data = associated_object_results.dig(:object_data)

    # Combine SES IDs from associated objects if any
    associated_ses_ids = associated_object_results.dig(:ses_ids)
    object_ses_ids = @object.ses_lookup_ids&.pluck(:value)
    all_ses_ids = associated_ses_ids.blank? ? object_ses_ids : object_ses_ids + associated_ses_ids

    # Use SesData class to handle SES retrieval from cache / API
    @ses_data = SesData.new(all_ses_ids).combined_ses_data

    # set description based on the object type
    unless @object.object_name.blank?
      @description = "A #{helpers.object_display_name(@object.object_name)} record in Parliamentary Search."
    end

    formatted_object_title = helpers.format_object_title(@object.object_title, @ses_data)
    @page_title = formatted_object_title
    @crumb << { label: formatted_object_title, url: nil }

    render template: @object.template, :locals => { :object => @object }
  end
end