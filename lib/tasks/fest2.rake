namespace :fest2 do
  desc "Download data from fest2 production into fest2_snapshot"
  task download: :environment do
    # The old database is latin1-encoded, but contains UTF8 data (!)...
    # download it to a local database and convert it.
    # database.yml's production entry matches our live server; we've also
    # got an extra local database configured that Fest2Importer will import from.
    require 'yaml'
    db_config = YAML::load(ERB.new(IO.read("config/database.yml")).result)
    config_prod = db_config['production']
    config_fest2 = db_config['fest2_snapshot']
    command = "ssh vertigo \"mysqldump --user=#{config_prod['username']} " +
      "--password=#{config_prod['password']} --add-drop-table " +
      "--default-character-set=latin1 --skip-set-charset " +
      "--skip-extended-insert #{config_prod['database']}\" | " +
      "sed 's/latin1/utf8/' | mysql --user #{config_fest2['username']} " +
      "--password=#{config_fest2['password']} #{config_fest2['database']}"
    puts command if (verbose == true || Rake.application.options.trace)
    `#{command}`
  end
end
