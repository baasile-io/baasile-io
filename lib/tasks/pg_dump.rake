namespace 'pg_dump' do
  desc "Import remote data"
  task :import => :environment do |t, args|

    target_database_config = Rails.configuration.database_configuration['development']

    puts "*** Restoring the database dump ***"

    system "psql --username=#{target_database_config['username']} --host=#{target_database_config['host']} --port=#{target_database_config['port']} --dbname=#{target_database_config['database']} --command='DROP SCHEMA public CASCADE; CREATE SCHEMA public;'"

    if system "pg_restore --no-owner --username=#{target_database_config['username']} --host=#{target_database_config['host']} --port=#{target_database_config['port']} --dbname=#{target_database_config['database']} tmp/latest_pg_dump.dump"

      puts ""
      puts "*** Database restoration done ***"
      puts ""

      puts "*** Migrating ***"
      Rake::Task["db:migrate"].invoke

      puts "*** All done, have fun! ***"
    else
      puts "*** ERROR ***"
    end

  end
end