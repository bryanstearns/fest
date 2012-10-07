source 'https://rubygems.org'

gem 'rails', '3.2.8'

gem 'jquery-rails'
gem 'mysql2'
gem 'turbolinks'

group :development do
  gem 'debugger' unless ENV['RM_INFO'] # don't if we're in RubyMine
  gem 'mailcatcher'
end

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
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
