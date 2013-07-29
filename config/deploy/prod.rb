set :application, 'fest_prod'
set :deploy_to, '/home/festprod'
set :branch, 'master' unless exists?(:branch)
set :rails_env, 'production'

set :user, 'festprod'
set :runner, 'festprod'

role :app, 'festprod'
role :web, 'festprod'
role :db, 'festprod', primary: true
