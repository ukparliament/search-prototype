class ApplicationController < ActionController::Base

  before_action :check_api_status

  def check_api_status
    # Make a simple SES request to check the service is working
    # This is skipped during tests

    unless Rails.env.test?
      check = SesLookup.new([{ value: 346696 }]).test_api_response

      if check.has_key?("error")
        render template: "layouts/shared/error/500", locals: { status: check.dig("error", "errorType"), message: check.dig("error", "errorMessage") }
      end
    end
  end

end
