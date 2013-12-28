set :application, 'fest_staging'
set :deploy_to, '/home/feststaging'
set :branch, 'master' unless exists?(:branch)
set :rails_env, 'staging'

set :user, 'feststaging'
set :runner, 'feststaging'

role :app, 'feststaging'
role :web, 'feststaging'
role :db, 'feststaging', primary: true

desc "copy production to staging"
task :db_fetch, :roles => :db do
  abort("Staging only!") unless fetch(:rails_env) == 'staging'
  `bundle exec rake db:fetch_production`
  upload("production.sql", "#{current_path}/production.sql", only: { primary: true })
  run "cd #{current_path}; RAILS_ENV=staging bundle exec rake db:load"
end

desc "clone the last festival in this GROUP for testing"
task :clone_festival, :roles => :db do
  abort("Staging only!") unless fetch(:rails_env) == 'staging'
  group = ENV['GROUP'] || 'piff'
  run "cd #{current_path}; RAILS_ENV=staging bundle exec rake clone_festival GROUP=#{group}"
end
