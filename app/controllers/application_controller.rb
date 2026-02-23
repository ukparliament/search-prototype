class ApplicationController < ActionController::Base
  include LibraryDesign::Crumbs

  $SITE_TITLE = 'Parliamentary Search'

  $TOGGLE_PORTCULLIS = ENV.fetch( "TOGGLE_PORTCULLIS", 'off' )
end
