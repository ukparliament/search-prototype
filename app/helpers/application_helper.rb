module ApplicationHelper
  
  # ## We set the date display format.
  DATE_DISPLAY_FORMAT = '%A, %e %B %Y'
  
  # ## A method to display the document type based on the SES ID.
  # NOTE: this should probably be replaced by a SES lookup.
  def document_type_display( document_type )
    
    # We check the document type and display document type label.
    case document_type
    when 93522
      'Written question'
    when 352211
      'Written statement'
    else
      'Document type unknown'
    end
  end
end