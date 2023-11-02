require 'open-uri'
# require 'net/http'


def when_online
  if URI.open("https://api.parliament.uk/")
  puts "online!"
    yield
  else
    puts "Skipping test offline."
  end
end
