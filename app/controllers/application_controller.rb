class ApplicationController < ActionController::Base
  include LibraryDesign::Crumbs
  
  $SITE_TITLE = 'Search Prototype'
  
  $TOGGLE_PORTCULLIS = ENV.fetch( "TOGGLE_PORTCULLIS", 'off' )
end
