class ObjectNotSupportedError < ApplicationError

  def initialize(parameter)
    super("Object type not supported: '#{parameter}'")
  end

end