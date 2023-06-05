class Result
  attr_accessor :title
  attr_accessor :uris
  attr_accessor :bibliographic_citations
  attr_accessor :data
  
  def display_title
    self.title || 'Untitled'
  end
end
