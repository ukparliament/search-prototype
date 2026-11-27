# frozen_string_literal: true

##
# Class to handle API-level errors
# Surfaces errors returned by an API and raises the appropriate Rails error
class ApiErrorHandler
  attr_reader :response

  def initialize(response: nil)
    @response = response
  end

  def handle_errors
    return response unless response.has_key?('error')

    error_message = response.dig('error', 'message') || response.dig('error', 'msg')

    case response.dig('error', 'code')&.to_i
    when 400
      raise ExternalServiceError.new(status: 400, body: error_message)
    when 401
      raise UnauthorizedError.new(status: 401, body: error_message)
    when 403
      raise UnauthorizedError.new(status: 403, body: error_message)
    when 404
      raise ObjectNotFoundError.new(status: 404, body: error_message)
    else
      raise ExternalServiceError.new(status: 500, body: error_message)
    end
  end
end
