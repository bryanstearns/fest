namespace :db do
  desc "Download a copy of the remote production database and replace the " +
           "local development database"
  task :fetch do
    puts "Retrieving production data"
    cmd = "mysqldump -ufest -pfest fest_prod"
    `ssh festprod "#{cmd}" > production.sql`
    load_data
  end

  desc "Replace the local development database with a previously-downloaded " +
           "copy of the remote production database"
  task :load do
    load_data
  end

  def load_data
    env = ENV["RAILS_ENV"] || 'development'
    raise "Can't load data into production" if env == "production"
    puts "Loading data"
    db_config = YAML::load(ERB.new(IO.read("config/database.yml")).result)
    `mysql -ufest -pfest #{db_config[env]["database"]} <production.sql`
    #`psql #{db_config[env]["database"]} -f production.sql`
    # Use taps to convert the data to postgress
    child = fork do
      puts "starting server"
      exec "bundle exec taps server mysql2://fest:fest@localhost/fest_#{env} t t"
    end
    sleep(2)
    puts 'Pulling data into Postgres'
    `bundle exec taps pull postgres://localhost/fest_#{env} http://t:t@localhost:5000`

    puts "Killing server"
    Process.kill('QUIT', child)
    Process.wait

    puts "Migrating"
    Rake::Task['db:migrate'].invoke
    if env == "development"
      puts "Cloning structure to test"
      Rake::Task['db:test:clone'].invoke
    end
    puts "Flushing redis cache"
    Redis.current.flushdb
  end

  # Notes on moving data from MySQL to postgres:
  # - (As of this writing, production still uses MySQL, but development uses
  #   postgresql.)
  # - Use 'rake db:fetch' to copy the production data into the local mysql
  #   fest_development database.
  # - Launch a taps server in the background, pointing at the local mysql database:
  #   /usr/local/opt/rbenv/versions/1.9.3-p327/lib/ruby/gems/1.9.1/gems/taps-0.3.24/bin/taps \
  #     server mysql://fest:fest@localhost/fest_development t t &
  # - Run taps to copy the data into the local production database:
  #   /usr/local/opt/rbenv/versions/1.9.3-p327/lib/ruby/gems/1.9.1/gems/taps-0.3.24/bin/taps \
  #     pull postgres://stearns@localhost/fest_development http://t:t@localhost:5000"
  # - fg, ctrl-C to kill the taps server.
  # - Don't forget to 'rake db:test:clone'
end
