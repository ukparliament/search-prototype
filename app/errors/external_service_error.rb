class ExternalServiceError < ApplicationError

  attr_reader :status, :body

  def initialize(status:, body:)
    @status = status
    @body = body

    super("API request failed (HTTP #{status})")
  end

end