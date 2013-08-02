set :application, 'fest_staging'
set :deploy_to, '/home/feststaging'
set :branch, 'master' unless exists?(:branch)
set :rails_env, 'staging'

set :user, 'feststaging'
set :runner, 'feststaging'

role :app, 'feststaging'
role :web, 'feststaging'
role :db, 'feststaging', primary: true
