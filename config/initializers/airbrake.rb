Airbrake.configure do |config|
  config.project_key = '48f876c18cf0ef128d95ef7a6f59800f'
  config.project_id = 17719
  config.environment = Rails.env
  config.ignore_environments = %w(development test)
end
