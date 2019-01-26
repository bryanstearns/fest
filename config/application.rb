require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Fest
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'Pacific Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Always use Redis, namespaced by our environment
    config.cache_store = :redis_cache_store, {url: ENV['REDIS_URL'] || "redis://localhost:6379/#{ENV['REDIS_DB'] || 0}/#{Rails.env}"}

    # Autoload lib stuff
    config.autoload_paths << Rails.root.join('lib')

    # Generate SASS please
    config.sass.preferred_syntax = :sass

    config.generators do |g|
      g.stylesheet_engine :sass
      g.test_framework :rspec
      g.view_specs false
      g.helper_specs false
    end
  end
end
