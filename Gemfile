source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.6"

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
gem "passenger", ">= 5.3.2", require: "phusion_passenger/rack_handler"

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
  gem "webdrivers"
  gem 'simplecov'
  gem 'rails-controller-testing'
end
