# frozen_string_literal: true

# Standard-library-only holding server. No gems, so nothing here constrains
# the application's eventual gem set. Replaced wholesale by the real app.

require "socket"

PORT = Integer(ENV.fetch("PORT", "8080"))

BODY = <<~HTML
  <!doctype html>
  <html lang="en"><head><meta charset="utf-8"><title>odp-search</title></head>
  <body><h1>odp-search</h1>
  <p>Placeholder image. The application has not been deployed yet.</p></body></html>
HTML

def respond(client, status, content_type, body)
  client.print "HTTP/1.1 #{status}\r\n"
  client.print "Content-Type: #{content_type}\r\n"
  client.print "Content-Length: #{body.bytesize}\r\n"
  client.print "Connection: close\r\n\r\n"
  client.print body
end

server = TCPServer.new("0.0.0.0", PORT)
$stdout.sync = true
puts %({"level":"info","msg":"placeholder server listening","port":#{PORT}})

loop do
  Thread.start(server.accept) do |client|
    request_line = client.gets.to_s
    path = request_line.split(" ")[1].to_s

    case path
    when "/health", "/up"
      respond(client, "200 OK", "application/json", %({"status":"ok"}))
    when "/"
      respond(client, "200 OK", "text/html; charset=utf-8", BODY)
    else
      respond(client, "404 Not Found", "application/json", %({"status":"not_found"}))
    end
  rescue StandardError => e
    puts %({"level":"error","msg":#{e.message.inspect}})
  ensure
    client.close rescue nil
  end
end
