class MissingParameterError < ApplicationError

  def initialize(parameter)
    super("Missing required parameter: '#{parameter}'")
  end

end