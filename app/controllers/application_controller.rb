class ApplicationController < ActionController::Base
  
  # We set the base API URI.
  BASE_API_URI = "https://api.parliament.uk/search-mock/"
  #BASE_API_URI = "http://localhost:3000/search-mock/"
  
  # We set the format we want to parse.
  API_FORMAT = 'json'
end
