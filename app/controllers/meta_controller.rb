class MetaController < ApplicationController

  def index
    @page_title = 'About this website'
    @description = 'About this website.'
    @crumb << { label: @page_title, url: nil }
  end

  def cookies
    @page_title = 'Cookie Policy'
    @description = 'Cookie Policy.'
    @crumb << { label: 'About this website', url: meta_cookies_url }
    @crumb << { label: @page_title, url: nil }
  end
  
  def coverage
    @page_title = 'Coverage'
    @description = 'Information about the content available in Parliamentary Search.'
    @crumb << { label: 'About this website', url: meta_cookies_url }
    @crumb << { label: @page_title, url: nil }
  end
  
  def examples
    @page_title = 'Example object pages'
    @description = 'Examples of object pages for each of the different content types available in Parliamentary Search.'
    @crumb << { label: 'About this website', url: meta_cookies_url }
    @crumb << { label: @page_title, url: nil }
  end
  
  def librarian_tools
    @page_title = 'Librarian tools'
    @description = 'Librarian tools.'
    @crumb << { label: 'About this website', url: meta_cookies_url }
    @crumb << { label: @page_title, url: nil }
  end

  def roadmap
    @page_title = 'Roadmap'
    @description = 'The roadmap for development of this website.'
    @crumb << { label: 'About this website', url: meta_cookies_url }
    @crumb << { label: @page_title, url: nil }
  end

end