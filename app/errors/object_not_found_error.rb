class ObjectNotFoundError < ExternalServiceError
  def initialize(parameter)
    super("Object not found for ID: '#{parameter}'")
  end

end