set :stages, Dir.glob('config/deploy/*.rb').map {|x| File.basename(x, '.rb')}
set :default_stage, 'soon'
require 'capistrano/ext/multistage'
require 'bundler/capistrano'

set :scm, :git
set :repository, 'git@github.com:bryanstearns/fest.git'
set :deploy_via, :remote_cache

set :user, 'www-data'
set :runner, 'www-data'
set :use_sudo, false
ssh_options[:forward_agent] = true
ssh_options[:verbose] = :debug if ENV['VERBOSE']

set :shared_files, %w[database.yml]

role :app, 'frenzy'
role :web, 'frenzy'
role :db, 'frenzy', primary: true

before "deploy:assets:precompile", "setup_shared_files"
after "deploy:create_symlink", "deploy:migrate"
after "deploy:restart", "restart_unicorns"

desc "Link shared files into the release tree"
task :setup_shared_files do
  shared_files.each do |f|
    run "ln -f #{shared_path}/#{f} #{release_path}/config/#{f}"
  end
  run "ln -fs #{shared_path}/log #{release_path}/"
end

desc "restart unicorn app instances"
task :restart_unicorns, :roles => :app, :except => {:no_release => true} do
  run "kill -USR2 `cat #{shared_path}/pids/unicorn.pid` || echo 'Unable to restart unicorns' 1>&2"
end
