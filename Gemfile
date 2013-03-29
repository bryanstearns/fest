source 'https://rubygems.org'

gem 'rails', '3.2.13'

gem 'airbrake'
gem 'axlsx_rails'
gem 'cache_digests'
gem 'capistrano-ext', require: false
gem 'capistrano-unicorn', require: false
gem 'jquery-rails'
gem 'bootstrap_modal_rails'
gem 'bootstrap-sass'
gem 'devise'
gem 'handlers-js'
gem 'mysql2'
gem 'newrelic_rpm'
gem 'pg'
gem 'prawn'
gem 'redis-rails'
gem 'simple_form'
gem 'turbolinks'
gem 'jquery-turbolinks'
gem 'taps', git: 'git://github.com/thedeeno/taps.git'
gem 'underscore-rails'
gem 'unicorn'

group :development do
  gem 'mailcatcher'
  gem 'quiet_assets'
  gem 'better_errors'
  gem 'binding_of_caller' # better_errors wants this
  gem 'factory_girl_rails', require: false

  if ENV['RM_INFO'] # Don't use the debugger when running under Rubymine
    gem 'debugger', require: false
  else
    gem 'debugger'
  end
end

group :assets do
  gem 'coffee-rails'
  gem 'jquery-ui-rails'
  gem 'sass-rails'
  gem 'uglifier'
end

group :test do
  gem 'capybara'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'email_spec'
  gem 'factory_girl_rails'
  gem 'guard-cucumber'
  gem 'guard-rspec'
  gem 'guard-spork'
  gem 'poltergeist'
  gem 'rb-inotify', :require => false # Guard will pick the right one of these
  gem 'rb-fsevent', :require => false
  gem 'rb-fchange', :require => false
  gem 'rspec-rails'
  gem 'rspec-instafail'
  gem 'shoulda-matchers'
  gem 'spork'
end
