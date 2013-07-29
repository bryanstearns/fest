set :application, 'fest_soon'
set :deploy_to, '/home/festsoon'
set :branch, 'master' unless exists?(:branch)
set :rails_env, 'soon'

set :user, 'festsoon'
set :runner, 'festsoon'

role :app, 'festsoon'
role :web, 'festsoon'
role :db, 'festsoon', primary: true
