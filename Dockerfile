
# Use the official Ruby image as a base
FROM ruby:3.3.6

# Set environment variables
ENV RAILS_ENV=production

# Install dependencies
RUN apt-get update -qq

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
# This complains if we con't give it a secret key base at all
# Doesn't work if we try ENV SECRET_KEY_BASE=$SECRET_KEY_BASE
# Nor if we add that after the RUN

RUN SECRET_KEY_BASE=12345 bundle exec rails assets:precompile

# Expose port 3000 to the outside world
EXPOSE 3000

# The command to run the application
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
