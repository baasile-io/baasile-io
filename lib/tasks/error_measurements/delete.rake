namespace 'error_measurements' do

  desc "delete old error measurement records"
  task :delete => :environment do
    count = ErrorMeasurement.old.count
    puts "Removing #{count} error measurement log(s)"

    ErrorMeasurement.old.destroy_all
  end

end