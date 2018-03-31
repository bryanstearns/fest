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
  task reload: ['db:drop', 'db:create'] do
    load_data
  end

  def fetch_data
    # Run this in another terminal:
    #   ssh $INTERNAL_PRODUCTION_HOSTNAME -N -L55432:172.17.42.1:5432
    # then run the rake task. For staging, fetch the production data locally,
    # then copy it to the staging container and load it there.)
    hostname = ENV["INTERNAL_PRODUCTION_HOSTNAME"]
    puts "Establishing connection to '#{hostname}'..."
    ssh_pid = spawn("ssh #{hostname} -N -L55432:172.17.42.1:5432")
    sleep(1.5)

    puts "Retrieving production data"
    db_config = YAML::load(ERB.new(IO.read("config/database.yml")).result)
    child_pid = nil
    loop do
      sleep 0.2
      `pg_isready -p 55432 -h localhost`
      break if $?.success?
      unless child_pid
        puts "connecting..."
        child_pid = fork do
          exec "ssh fest_prod -N -L55432:localhost:5432 2>/dev/null"
        end
      end
    end
    cmd = "PGPASSWORD=#{db_config['production']['password']} pg_dump --clean --no-owner --no-privileges #{db_config['production']['database']} -h localhost -p 55432 -U #{db_config['production']['username']}"
    cmd += " | egrep -v ^[^\\']+plpgsql | egrep -v ^[^\\']+SCHEMA\\ public"
    cmd += " | egrep -v ^[^\\']+EXTENSION\\ hstore"
    cmd += " > fest_prod.sql"
    puts "dumping..."
    `#{cmd}`
    abort unless $?.success?
    puts "done."
  ensure
    if child_pid
      puts "disconnecting from postgres"
      Process.kill('TERM', child_pid)
    end

    if ssh_pid
      puts "disconnecting from '#{hostname}'"
      Process.kill('TERM', ssh_pid)
    end
  end

  def load_data
    env = ENV["RAILS_ENV"] || 'development'
    raise "Can't load data into production" if env == "production"
    puts "Loading data"
    db_config = YAML::load(ERB.new(IO.read("config/database.yml")).result)[env]
    user = db_config["username"] ? "-U #{db_config["username"]} " : ""
    password = db_config["password"] ? "PGPASSWORD=#{db_config["password"]} " : ""
    host = db_config["host"] ? "-h #{db_config["host"]} " : ""
    port = db_config["port"] ? "-p #{db_config["port"]} " : ""
    `#{password}psql -d #{db_config["database"]} #{host} #{user} #{port}-f fest_prod.sql`
    abort unless $?.success?

    puts "Migrating"
    `rake db:migrate`
    abort unless $?.success?

    puts "Flushing redis cache"
    Redis.current.flushdb

    Rake::Task['environment'].invoke
    if env == "development" && !Festival.have_testable_festival?
      puts "Cloning last PIFF festival"
      `rake clone_festival GROUP=piff`
      abort unless $?.success?
    end
    puts "done."
  end
end
