class QueryValidationError < ApplicationError

  def initialize(token)
    super("Query validation failed: '#{token}'")
  end

end