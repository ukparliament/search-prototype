# # The one and only search controller.
class ErrorsController < ApplicationController

  def not_found
    @page_title = "Page not found"
    @crumb << { label: @page_title, url: nil }
  end

  def internal_server_error
    @page_title = "Internal Server Error"
    @crumb << { label: @page_title, url: nil }
  end

  def not_authorized
    @page_title = "Not Authorized"
    @crumb << { label: @page_title, url: nil }
  end
end
