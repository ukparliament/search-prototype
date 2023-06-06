require 'nokogiri'
require 'json'
require 'open-uri'
require 'uri'
require 'net/http'
require 'pp'

class SearchController < ApplicationController
  
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
  
  def results
    @page_title = 'Search results'
    
    # We get the document type from the URL parameter.
    document_type = params[:document_type]
    
    # We construct the URI to grab the XML from.
    uri = "#{BASE_API_URI}results/#{document_type}.rb"
    
    
      
    
    
    

    uri = URI( uri )
    body = Net::HTTP.get_response( uri ).body
    evaluated = eval(body)
    render :template => 'search/results', :locals => { :results => evaluated }
  end
  
  def object
    object = params[:object]
    
    # We construct the URL to grab the data from.
    uri = "#{BASE_API_URI}objects/#{object}"
    
    # We load the data.
    json = JSON.load( URI.open( uri ) )
    
    # We create a new search object.
    @search_object = SearchObject.new
      
    # ... and assign its attributes.
    @search_object.id = json['id']
    @search_object.title = json['title']
    @search_object.description = json['description']
    @search_object.link = json['link']
    
    # We set the page title to the title of the object.
    @page_title = @search_object.title
  end
end
