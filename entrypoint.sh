#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /app/tmp/pids/server.pid

# Ensure the directories for Puma sockets and logs exist
mkdir -p /app/tmp/sockets /app/tmp/pids /app/log

# Start Nginx in the background
service nginx start

# Start Puma
bundle exec puma -C config/puma.rb
