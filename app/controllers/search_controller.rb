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
    
    # We get the document type from the URL parameter.
    document_type = params[:document_type]
    
    # We construct the URI to grab the XML from.
    uri = "#{BASE_API_URI}results/#{document_type}"
    
    # We load the data.
    xml = Nokogiri::XML( URI.open( uri ) )
    
    # We create a new result set object.
    @result_set = ResultSet.new
    
    # We parse the results XML.
    parse_results( xml )
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
  
  # ## A method to parse the result set XML.
  def parse_results( xml )
    
    # We store the returned variables.
    query = xml.xpath( 'response/lst/lst[@name="params"]/str[@name="q"]/text()' ).to_s
    result_count = xml.xpath( 'response/result/@numFound' ).to_s
    query_time = xml.xpath( 'response/lst/int[@name="QTime"]/text()' ).to_s
    offset = xml.xpath( 'response/lst/lst[@name="params"]/str[@name="start"]/text()' ).to_s
    limit = xml.xpath( 'response/lst/lst[@name="params"]/str[@name="rows"]/text()' ).to_s
    status = xml.xpath( 'response/lst/int[@name="status"]/text()' ).to_s
    version = xml.xpath( 'response/lst/lst[@name="params"]/str[@name="version"]/text()' ).to_s
    
    # We assign properties to the result set object.
    @result_set.query = query
    @result_set.result_count = result_count
    @result_set.query_time = query_time
    @result_set.offset = offset
    @result_set.limit = limit
    @result_set.status = status
    @result_set.version = version
    
    # We create an array to hold the results.
    @result_set.results = []
    
    # For each result item returned ...
    xml.xpath( 'response/result/doc' ).each do |result_document|
      
      # ... we parse a result item.
      parse_result_item( result_document )
    end
  end
  
  # ## A method to parse the result item XML.
  def parse_result_item( result_document )
    
    # We store the returned variables.
    title = result_document.xpath( 'str[@name="title_t"]/text()' ).to_s
    
    # ... we create a new result object ...
    result = Result.new
    
    # We assign properties to the result object.
    result.title = title
    result.xml = result_document
    
    # ... and add the result to the resultset array.
    @result_set.results << result
  end
end
