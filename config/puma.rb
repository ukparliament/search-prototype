# Change to match your CPU core count
workers ENV.fetch("WEB_CONCURRENCY") { 2 }

# Min and Max threads per worker
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count

preload_app!

# Specify the port Puma will listen on
port        ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "development" }

# Set up socket location
bind "unix:///app/tmp/sockets/puma.sock"

# Logging
stdout_redirect "/app/log/puma.stdout.log", "/app/log/puma.stderr.log", true

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
