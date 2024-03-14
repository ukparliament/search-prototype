# # The one and only search controller.
class ErrorsController < ApplicationController

  def internal_server_error
    @page_title = "Example 500 error"
    render template: 'layouts/shared/error/500', locals: { status: 500, message: "Internal server error" }
  end

  def not_found
    @page_title = "Example 404 error"
    render template: 'layouts/shared/error/404', locals: { status: 404, message: "Page not found" }
  end

  def not_authorized
    @page_title = "Example 401 error"
    render template: 'layouts/shared/error/401', locals: { status: 401, message: "Not authorized" }
  end
end
