class Rss < SolrSearch
require 'rss'
require 'open-uri'

def initialize(search_parameters)
  super
end

def read
  # example reading
  url = './lib/assets/example.rss'
  open(url) do |rss|
    feed = RSS::Parser.parse(rss)
    puts "Title: #{feed.channel.title}"
    feed.items.each do |item|
      puts "Item: #{item.title}"
    end
  end
end


def write
  # example write
  rss = RSS::Maker.make("atom") do |maker|
    maker.channel.author = "matz"
    maker.channel.updated = Time.now.to_s
    maker.channel.about = "http://www.ruby-lang.org/en/feeds/news.rss"
    maker.channel.title = "Search Results"

    maker.items.new_item do |item|
      item.link = "http://www.ruby-lang.org/en/news/2010/12/25/ruby-1-9-2-p136-is-released/"
      item.title = "Ruby 1.9.2-p136 is released"
      item.updated = Time.now.to_s
    end
  end

  puts rss
end

end

