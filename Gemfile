source 'https://rubygems.org'

gem 'rails', '3.2.9'

gem 'jquery-rails'
gem 'bootstrap-sass'
gem 'devise'
gem 'mysql2'
gem 'simple_form'
gem 'turbolinks'

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
  gem 'rspec-rails'
  gem 'shoulda-matchers'
end
