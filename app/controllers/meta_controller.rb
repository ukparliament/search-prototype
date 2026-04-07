class MetaController < ApplicationController

  def index
    @page_title = 'About this website'
    @description = 'About this website.'
    @crumb << { label: @page_title, url: nil }
    @heading_one = @page_title
  end

  def cookies
    @page_title = 'Cookies'
    @description = 'Cookie Policy.'
    @crumb << { label: 'About this website', url: meta_list_url }
    @crumb << { label: @page_title, url: nil }
    @heading_one = @page_title

    render 'library_design/meta/cookies'
  end
  
  def coverage
    @page_title = 'Coverage'
    @description = 'Coverage.'
    @crumb << { label: 'About this website', url: meta_list_url }
    @crumb << { label: @page_title, url: nil }
    @heading_one = @page_title
  end
  
  def examples
    @page_title = 'Example object pages'
    @description = 'Example object pages.'
    @crumb << { label: 'About this website', url: meta_list_url }
    @crumb << { label: @page_title, url: nil }
    @heading_one = @page_title
  end
  
  def librarian_tools
    @page_title = 'Librarian tools'
    @description = 'Librarian tools.'
    @crumb << { label: 'About this website', url: meta_list_url }
    @crumb << { label: @page_title, url: nil }
    @heading_one = @page_title
  end

  def roadmap
    @page_title = 'Roadmap'
    @description = 'Roadmap.'
    @crumb << { label: 'About this website', url: meta_list_url }
    @crumb << { label: @page_title, url: nil }
    @heading_one = @page_title
  end

end