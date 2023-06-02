class Result
  attr_accessor :title
  attr_accessor :uris
  attr_accessor :xml
  
  def display_title
    self.title || 'Untitled'
  end
end
