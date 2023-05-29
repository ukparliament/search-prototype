class MetaController < ApplicationController
  
  def index
    @page_title = 'Meta'
  end
  
  def about
    @page_title = 'About'
  end
  
  def coverage
    @page_title = 'Content coverage'
  end
  
  def contact
    @page_title = 'Contact'
  end
end
