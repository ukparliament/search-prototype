require 'nokogiri'
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
    xml = Nokogiri::XML( URI.open( uri ) )
    
    # We create a new resultset object.
    @result_set = ResultSet.new
    
    # We grab the resultset attributes from the data.
    @result_set.query = xml.xpath( 'response/lst/lst[@name="params"]/str[@name="q"]/text()' ).to_s
    @result_set.result_count = xml.xpath( 'response/result/@numFound' ).to_s
    @result_set.query_time = xml.xpath( 'response/lst/int[@name="QTime"]/text()' ).to_s
    @result_set.offset = xml.xpath( 'response/lst/lst[@name="params"]/str[@name="start"]/text()' ).to_s
    @result_set.limit = xml.xpath( 'response/lst/lst[@name="params"]/str[@name="rows"]/text()' ).to_s
    @result_set.status = xml.xpath( 'response/lst/int[@name="status"]/text()' ).to_s
    @result_set.version = xml.xpath( 'response/lst/lst[@name="params"]/str[@name="version"]/text()' ).to_s
    
    # We create an array to hold the results.
    @result_set.results = []
    
    # For each result item returned ...
    xml.xpath( 'response/result/doc' ).each do |result_document|
      
      # ... we create a new result ...
      result = Result.new
      result.xml = result_document
      
      # ... assign it's attributes ...
      #result.id = result_item['id']
      #result.title = result_item['title']
      #result.description = result_item['description']
      #result.link = result_item['link']
      
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
    
    # We set the page title to the title of the object.
    @page_title = @search_object.title
  end
end
