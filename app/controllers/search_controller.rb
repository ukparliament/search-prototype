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
    
    # We construct the URL string to grab the XML from.
    url = "#{BASE_API_URI}results/#{document_type}.rb"
    
    # We turn the URL string into a RUBY URI.
    uri = URI( url )
    
    # We get the body of the response from deferencing the URI.
    response_body = Net::HTTP.get_response( uri ).body
    
    # We evaluate the body and construct a Ruby hash.
    evaluated = eval( response_body )
    
    # We render the search results template, passing the evaluated response body as results.
    render :template => 'search/results', :locals => { :results => evaluated }
  end
  
  def object
    
    # We get the object URI passed as a parameter.
    object_uri = params[:object]
    
    # We construct the URL string to grab the XML from.
    url = "#{BASE_API_URI}object/#{object_uri}.rb"
    
    # We turn the URL string into a RUBY URI.
    uri = URI( url )
    
    # We get the body of the response from deferencing the URI.
    response_body = Net::HTTP.get_response( uri ).body
    
    # We evaluate the body and construct a Ruby hash.
    evaluated = eval( response_body )
    
    # We render the object template, passing the evaluated response body as object.
    render :template => 'search/object', :locals => { :object => evaluated }
  end
end
