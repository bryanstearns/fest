namespace :db do
  desc "Download a copy of the remote production database and replace the " +
           "local development database"
  task :fetch do
    puts "Retrieving production data"
    # cmd = "mysqldump -ufest -pfest fest_prod"
    # `ssh festprod "#{cmd}" > production.sql`
    cmd = "mysqldump -ufest -pfest --add-drop-table --skip-set-charset " +
          "--default-character-set=latin1 --skip-extended-insert --skip-quick " +
          "fest_production"
    `ssh oldfestivalfanatic "#{cmd}" > production.sql`
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
    `mysql -ufest -pfest fest2_snapshot <production.sql`

    #puts "Recreating database"
    #`r --create`
    #puts "Loading data"
    #db_config = YAML::load(ERB.new(IO.read("config/database.yml")).result)
    #`mysql -ufest -pfest #{db_config[env]["database"]} <production.sql`
    #puts "Migrating"
    #Rake::Task['db:migrate'].invoke
    ##Rake::Task['db:check'].invoke
    #if env == "development"
    #  puts "Cloning structure to test"
    #  Rake::Task['db:test:clone'].invoke
    #end
  end
end
