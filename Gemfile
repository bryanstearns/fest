source 'https://rubygems.org'

gem 'rails', '3.2.8'

gem 'jquery-rails'
gem 'bootstrap-sass'
gem 'devise'
gem 'mysql2'
gem 'simple_form'
gem 'turbolinks'

group :development do
  gem 'debugger' unless ENV['RM_INFO'] # do when bundling, don't when in RubyMine
  gem 'mailcatcher'
end

group :assets do
  gem 'coffee-rails', '~> 3.2.1'
  gem 'jquery-ui-rails'
  gem 'sass-rails',   '~> 3.2.3'
  gem 'uglifier', '>= 1.0.3'
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
