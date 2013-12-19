set :stages, Dir.glob('config/deploy/*.rb').map {|x| File.basename(x, '.rb')}
set :default_stage, 'prod'
require 'capistrano/ext/multistage'
require 'bundler/capistrano'
require 'new_relic/recipes'

set :scm, :git
set :repository, 'git@github.com:bryanstearns/fest.git'
set :deploy_via, :remote_cache

default_run_options[:shell] = '/bin/bash --login'
set :use_sudo, false
if ENV['VERBOSE']
  set :ssh_options, { :forward_agent => true, :verbose => :debug }
else
  set :ssh_options, { :forward_agent => true }
end

# Chef's application cookbook sets up shared/vendor_bundle instead of
# bundler/capistrano's default shared/bundle. So, for now:
set(:bundle_dir) { File.join(fetch(:shared_path), 'vendor_bundle') }

set :shared_files, %w[database.yml newrelic.yml secret_token devise_key]

before "deploy:assets:precompile", "setup_shared_files"
after "deploy:create_symlink", "deploy:migrate"
after "deploy:restart", "restart_unicorns"
after "deploy:restart", "newrelic:notice_deployment"

desc "Link shared files into the release tree"
task :setup_shared_files do
  shared_files.each do |f|
    run "ln -f #{shared_path}/#{f} #{release_path}/config/#{f}"
  end
  run "ln -fs #{shared_path}/log #{release_path}/"
end

desc "restart unicorn app instances"
task :restart_unicorns, :roles => :app, :except => {:no_release => true} do
  run "#{shared_path}/unicorn_restart"
end

desc "flush the redis cache"
task :flush_redis_cache, :roles => :app do
  run "redis-cli flushall"
end
