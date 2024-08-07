
# Use the official Ruby image as a base
FROM ruby:3.3.1

# Set environment variables
ENV RAILS_ENV development

# Install dependencies
RUN apt-get update -qq && apt-get install -y nginx

# Set the working directory
WORKDIR /app

# Copy the Gemfile and Gemfile.lock into the image
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

# Install gems
RUN bundle install

# Copy the rest of the application code
COPY . /app

# Precompile assets (if you have any)
RUN bundle exec rails assets:precompile

# Copy entrypoint script
COPY entrypoint.sh /usr/bin/

# Configure Nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Ensure the directories for Puma sockets and logs exist
RUN mkdir -p /app/tmp/sockets /app/tmp/pids /app/log

# Expose port 80 as we're using nginx as a reverse proxy
EXPOSE 80

# Set entry point script as the container's entry point
ENTRYPOINT ["entrypoint.sh"]
