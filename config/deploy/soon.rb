set :application, 'fest_soon'
set :deployed_url, 'http://soonfest/'
set :deploy_to, '/var/www/fest_soon'
set :branch, 'master' unless exists?(:branch)
set :rails_env, 'soon'
