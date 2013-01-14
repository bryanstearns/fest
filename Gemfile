source 'https://rubygems.org'

gem 'rails', '3.2.11'

gem 'cache_digests'
gem 'jquery-rails'
gem 'bootstrap_modal_rails'
gem 'bootstrap-sass'
gem 'devise'
gem 'mysql2'
gem 'redis-rails'
gem 'simple_form'
gem 'turbolinks'
gem 'jquery-turbolinks'

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
  gem 'rb-inotify', :require => false # Guard will pick the right one of these
  gem 'rb-fsevent', :require => false
  gem 'rb-fchange', :require => false
  gem 'rspec-rails'
  gem 'rspec-instafail'
  gem 'shoulda-matchers'
  gem 'spork'
end
