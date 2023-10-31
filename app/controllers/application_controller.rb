class ApplicationController < ActionController::Base

  def url_options
    super.except(:script_name).merge({ only_path: true })
  end

  # TODO: Move these to appropriate class
  # We set the base API URI.
  BASE_API_URI = "https://api.parliament.uk/search-mock/"
  #BASE_API_URI = "http://localhost:3000/search-mock/"
end
