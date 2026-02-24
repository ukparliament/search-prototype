class ApplicationController < ActionController::Base
  include LibraryDesign::Crumbs

  $SITE_TITLE = 'Parliamentary Search'
  $TOGGLE_PORTCULLIS = Rails.application.credentials.dig(:portcullis)
end
