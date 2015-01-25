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
    # to make this work, ~/.ssh/config has:
    #   Host fest_prod
    #     Hostname _internal_production_box_hostname_
    #     ProxyCommand ssh -W %h:%p -p _gateway_ssh_port_ -L5432:localhost:5432 my_username@my_gateway_domain
    puts "Retrieving production data"
    db_config = YAML::load(ERB.new(IO.read("config/database.yml")).result)
    child = nil
    loop do
      sleep 0.2
      `pg_isready -p 55432 -h localhost`
      break if $?.success?
      unless child
        puts "connecting..."
        child = fork do
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
    if child
      puts "disconnecting"
      Process.kill('TERM', child)
    end
  end

  def load_data
    env = ENV["RAILS_ENV"] || 'development'
    raise "Can't load data into production" if env == "production"
    puts "Loading data"
    db_config = YAML::load(ERB.new(IO.read("config/database.yml")).result)
    `psql -d #{db_config[env]["database"]} -f fest_prod.sql`

    puts "Migrating"
    `rake db:migrate`

    puts "Flushing redis cache"
    Redis.current.flushdb

    Rake::Task['environment'].invoke
    if env == "development" && !Festival.have_testable_festival?
      puts "Cloning last PIFF festival"
      `rake clone_festival GROUP=piff`
    end
  end
end
