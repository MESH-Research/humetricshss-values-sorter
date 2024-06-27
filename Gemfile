# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.7.3"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 6.1.0"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use Puma as the app server
gem "puma", "~> 5.0"
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem "webpacker", "~> 5.0"
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem "turbolinks", "~> 5"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.7"
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'
gem "pg_search", "~> 2.3"
# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.4", require: false

# Use pry for rails console
gem "pry-rails", "~> 0.3"

# Data transformation for import process
gem "reforge", "~> 0.1"

# User authentication
gem "devise", "~> 4.7"

# Administration
gem "activeadmin", "~> 2.9"

# Authorization
gem "pundit", "~> 2.1"

# Cleaner forms
gem "simple_form", "~> 5.1"

# ORCID OAuth
gem "omniauth-orcid", "~> 2.1"
gem "omniauth-rails_csrf_protection", "~> 1.0"

group :development, :test do
  # Integrate pry and byebug
  gem "pry-byebug", "~> 3.9"
  # Use rspec as test framework
  gem "rspec-rails", "~> 5.0"
  # Use rubocop for linting
  # - default to same config used for Rails project
  # - additional performance-enhancing rules
  # - additional rules for checking rspec files
  gem "rubocop-rails", "~> 2.12"
  gem "rubocop-rails_config", "~> 1.7"
  gem "rubocop-performance", "~> 1.12"
  gem "rubocop-rspec", "~> 2.5"
  # Additional linting with erblint
  gem "erb_lint", "~> 0.1"
  # Use factory_bot instead of fixtures
  gem "factory_bot_rails", "~> 6.2"
  # Static code anaysis
  gem "brakeman", "~> 5.1"
  # Fake data generation
  gem "faker", "~> 2.19"
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", ">= 4.1.0"
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem "rack-mini-profiler", "~> 2.0"
  gem "listen", "~> 3.3"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring", "~> 3.0"
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", ">= 3.26"
  gem "selenium-webdriver", "~> 4.0"
  # Easy installation and use of web drivers to run system tests with browsers
  gem "webdrivers", "~> 5.0"
  # Better output for large rspec diffs
  gem "super_diff", "~> 0.8"
end
