class MetaController < ApplicationController

  def index
    @page_title = 'About this website'
    @description = 'About this website.'
    @crumb << { label: 'About this website', url: nil }
  end

  def cookies
    @page_title = 'Cookies'
    @description = 'Cookie Policy.'
    @crumb << { label: 'Meta', url: meta_list_url }
    @crumb << { label: 'Cookies', url: nil }

    render 'library_design/meta/cookies'
  end

  def examples
    @page_title = 'Examples'
  end

  def roadmap
    @page_title = 'Roadmap'
  end

  def coverage
    @page_title = 'Coverage'
  end

end