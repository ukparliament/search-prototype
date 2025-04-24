source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby file: '.ruby-version'

gem "rails", ">= 7.1.3.2"
gem 'bundler-audit'
gem "sqlite3", "~> 1.4"
gem "sprockets-rails"
gem "importmap-rails"
gem "font-awesome-rails"
gem "haml"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]
gem "bootsnap", require: false
# gem "puma"
gem "passenger", ">= 6", require: "phusion_passenger/rack_handler"

# Temporarily required until Rails update with Ruby 3.4
gem 'logger'
gem 'benchmark'
gem 'ostruct'
gem 'observer'

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem "faker"
end

group :development do
  gem "web-console"
  gem "better_errors"
  gem "binding_of_caller"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem 'simplecov'
  gem 'rails-controller-testing'
end
