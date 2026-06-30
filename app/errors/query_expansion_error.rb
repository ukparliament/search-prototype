class QueryExpansionError < ApplicationError
  def initialize(parameter)
    super(": '#{parameter}'")
  end

end