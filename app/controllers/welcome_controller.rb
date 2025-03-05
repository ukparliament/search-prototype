class WelcomeController < ApplicationController

  layout "narrow"

  def index
    @page_title = 'Parliamentary Search'
  end

end