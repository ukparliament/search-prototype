require 'open-uri'
require 'net/http'

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
    response_body = Net::HTTP.get_response( uri ).body
    
    # We evaluate the body and construct a Ruby hash.
    evaluated = eval( response_body )
    
    # We render the search results template, passing the evaluated response body as results.
    render :template => 'search/results/results', :locals => { :results => evaluated }
  end
  
  # A method to render the object page.
  def object
    
    # We get the object URI passed as a parameter.
    @object_uri = params[:object]
    
    # We construct the URL string to grab the XML from.
    url = "#{BASE_API_URI}objects.rb?object=#{@object_uri}"
    
    # We parse the URL string into a Ruby URI.
    uri = URI.parse( url )
    
    # We get the body of the response from deferencing the URI.
    response_body = Net::HTTP.get_response( uri ).body
    
    # We evaluate the body and construct a Ruby hash.
    evaluated = eval( response_body )
    
    # We get the object.
    object = evaluated['response']['docs'].first
    
    # We set the page title and the content type.
    @page_title = object['title_t']
    @content_type = object['type_ses'].first
    
    # We render the appropriate template based on the content type.
    case @content_type
    when 90996
      render :template => 'search/objects/edm', :locals => { :object => object }
    when 346697
      render :template => 'search/objects/research_briefing', :locals => { :object => object }
    when 93522
      render :template => 'search/objects/written_question', :locals => { :object => object }
    when 352211
      render :template => 'search/objects/written_statement', :locals => { :object => object }
    else
      render :template => 'search/objects/fallback', :locals => { :object => object }
    end
  end
end
