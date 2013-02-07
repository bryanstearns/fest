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
    puts "Migrating"
    Rake::Task['db:migrate'].invoke
    if env == "development"
      puts "Cloning structure to test"
      Rake::Task['db:test:clone'].invoke
    end
    puts "Flushing redis cache"
    Redis.current.flushdb
  end
end
