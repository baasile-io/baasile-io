#
# Options:
#   1. destination tenant # default: nil
#   2. source tenant      # default: adecco
#   3. anonymise ?        # default: false
#   3. fresh db ?         # default: true
#
# rake 'anonymise_data:import[staging]' for an existing 'staging' schema
# rake 'anonymise_data:import[panoptes,adecco,false,false]' for an existing 'panoptes' schema
#

namespace 'pg_dump' do
  desc "Import remote data"
  task :import => :environment do |t, args|

    target_database_config = Rails.configuration.database_configuration['development']

    puts "*** Restoring the database dump ***"

    system "psql -U #{target_database_config['username']} -h #{target_database_config['host']} -d #{target_database_config['database']} -c 'DROP SCHEMA public CASCADE; CREATE SCHEMA public;'"

    if system "pg_restore -O -U #{target_database_config['username']} -h #{target_database_config['host']} -d #{target_database_config['database']} tmp/latest_pg_dump.dump"

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