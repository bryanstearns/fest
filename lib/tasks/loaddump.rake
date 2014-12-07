namespace :db do
  desc "Download a copy of the remote production database and replace the " +
           "local development database"
  task :fetch do
    fetch_data
    load_data
  end

  desc "Download a copy of the remote production database"
  task :fetch_production do
    fetch_data
  end

  desc "Replace the local development database with a previously-downloaded " +
           "copy of the remote production database"
  task :load do
    load_data
  end

  desc "Drop and reload the local development database from a previously-" +
           "downloaded copy of production data"
  task reload: ['db:drop', 'db:create', 'db:migrate'] do
    load_data
  end

  def fetch_data
    puts "Retrieving production data"
    cmd = "ssh festprod@festprod \"pg_dump --clean --no-owner --no-privileges fest_prod\""
    cmd += " | egrep -v ^[^\\']+plpgsql | egrep -v ^[^\\']+SCHEMA\\ public"
    cmd += " | egrep -v ^[^\\']+EXTENSION\\ hstore"
    cmd += " > production.sql"
    `#{cmd}`
  end

  def load_data
    env = ENV["RAILS_ENV"] || 'development'
    raise "Can't load data into production" if env == "production"
    puts "Loading data"
    db_config = YAML::load(ERB.new(IO.read("config/database.yml")).result)
    `psql -d #{db_config[env]["database"]} -f production.sql`

    puts "Migrating"
    `rake db:migrate`
    # Rake::Task['db:migrate'].invoke
    if env == "development"
      puts "Cloning structure to test"
      `rake db:test:clone`
      # Rake::Task['db:test:clone'].invoke
    end
    puts "Flushing redis cache"
    Redis.current.flushdb

    if env == "development" && !Festival.upcoming_or_current
      puts "Cloning last PIFF festival"
      `rake clone_festival GROUP=piff`
    end
  end
end
