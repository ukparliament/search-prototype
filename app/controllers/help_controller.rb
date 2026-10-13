class HelpController < ApplicationController

  layout 'help'

  def index
    @page_title = 'Search Help'
    @description = 'Useful information for using the Search application.'
    @crumb << { label: @page_title, url: nil }
  end

  def aliases
    @page_title = 'Using aliases'
    @description = 'Using search aliases.'
    @crumb << { label: @page_title, url: nil }

    @markdown_content = MarkdownDocument.new('lib/aliases.md')
    @headings = @markdown_content.headings
    @alphabetised_headings = @markdown_content.alphabetised_headings
  end
end
