# # The one and only search controller.
class SearchController < ApplicationController
  
  # A method to render the search form.
  def form
    @page_title = 'Search'
    
    # We construct the URL to grab the data from.
    uri = "#{BASE_API_URI}form"
    
    # We load the data.
    json = JSON.load( URI.open( uri ) )
    
    # We create a new form object.
    @form = Form.new
    
    # We grab the attributes from the data.
    @form.title = json['title']
    @form.description = json['description']
  end
  
  # ## A method to render a results page.
  def results
    @page_title = 'Search results'
    
    # We get the document type from the URL parameter.
    document_type = params[:document_type]
    
    # We construct the URL string to grab the XML from.
    url = "#{BASE_API_URI}results/#{document_type}.rb"
    
    # We turn the URL string into a RUBY URI.
    uri = URI( url )
    
    # We get the body of the response from deferencing the URI.
    response_body = Net::HTTP.get( uri )
    
    # We evaluate the body and construct a Ruby hash.
    evaluated = eval( response_body )
    
    # We render the search results template, passing the evaluated response body as results.
    render :template => 'search/results/results', :locals => { :results => evaluated }
  end
end
