source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby file: '.ruby-version'

gem "rails", "8.1.2"
gem 'bundler-audit'
gem 'cgi'
gem 'fiddle'
gem "pg"
gem "propshaft"
gem "library_design", github: "ukparliament/design-assets", glob: 'library_design/*.gemspec', tag: "0.6.10"
gem "importmap-rails"
gem "haml"
gem 'rack-attack'
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]
gem "bootsnap", require: false
gem "passenger", ">= 6", require: "phusion_passenger/rack_handler"

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem "faker"
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem 'simplecov'
  gem 'rails-controller-testing'
end
