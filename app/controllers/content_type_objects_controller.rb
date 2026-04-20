class ContentTypeObjectsController < ApplicationController

  def show
    # fetch object data
    object_data = SolrQuery.new(object_uri: params[:object]).object_data

    # construct the object
    @object = ContentTypeObject.generate(object_data)

    # fetch associated object data
    associated_object_results = AssociatedObjectsForObjectView.new(@object).data
    @associated_object_data = associated_object_results.dig(:object_data)

    # Combine SES IDs from associated objects if any
    associated_ses_ids = associated_object_results.dig(:ses_ids)
    object_ses_ids = @object.ses_lookup_ids&.pluck(:value)
    all_ses_ids = associated_ses_ids.blank? ? object_ses_ids : object_ses_ids + associated_ses_ids

    # Use SesData class to handle SES retrival from cache / API
    @ses_data = SesData.new(all_ses_ids).combined_ses_data

    @page_title = "#{@object.object_title}"
    @crumb << { label: @object.object_title, url: nil }

    render template: @object.template, :locals => { :object => @object }
  end
end