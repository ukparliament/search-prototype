require 'open-uri'

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
    
    # We construct the URL to grab the data from.
    uri = "#{BASE_API_URI}results"
    
    # We load the data.
    json = JSON.load( URI.open( uri ) )
    
    # We create a new resultset object.
    @result_set = ResultSet.new
    
    # We grab the resultset attributes from the data.
    @result_set.result_count = json['result_set']['result_count']
    @result_set.limit = json['result_set']['limit']
    @result_set.offset = json['result_set']['offset']
    
    # We create an array to hold the results.
    @result_set.results = []
    
    # For each result item returned ...
    json['results'].each do |result_item|
      
      # ... we create a new result ...
      result = Result.new
      
      # ... assign it's attributes ...
      result.id = result_item['id']
      result.title = result_item['title']
      result.description = result_item['description']
      result.link = result_item['link']
      
      # ... and add the result to the resultset array.
      @result_set.results << result
    end
  end
  
  def object
    object = params[:object]
    
    # We construct the URL to grab the data from.
    uri = "#{BASE_API_URI}objects/#{object}"
    
    # We load the data.
    json = JSON.load( URI.open( uri ) )
    
    # We create a new search object.
    @search_object = SearchObject.new
      
    # ... and assign it's attributes.
    @search_object.id = json['id']
    @search_object.title = json['title']
    @search_object.description = json['description']
    @search_object.link = json['link']
    
    @page_title = @search_object.title
    
    
    
  end
end
