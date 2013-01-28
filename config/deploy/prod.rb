set :application, 'fest_prod'
set :deployed_url, 'http://prodfest/'
set :deploy_to, '/var/www/fest_prod'
set :branch, 'master' unless exists?(:branch)
set :rails_env, 'production'
