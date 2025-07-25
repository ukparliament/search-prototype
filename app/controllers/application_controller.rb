class ApplicationController < ActionController::Base
  include LibraryDesign::Crumbs

  $SITE_TITLE = 'Search prototype'
end
