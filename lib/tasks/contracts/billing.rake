# rake 'contracts:billing'

namespace 'contracts' do
  desc "Billing task"
  task :billing, [:date] => :environment do |t, args|
    today = if args.date.present?
              Date.strptime(args.date, "%Y-%m-%d")
            else
              Date.today
            end

    #####ContractRenewalService

    Contract.active_around(today).each do |contract|
      begin
        Bill.transaction do
          puts "Processing contract #{contract.id}"
          if contract.bills.by_month(today).exists?
            puts "#{contract.id}: Already billed"
          else

            billing_service = Bills::BillingService.new(contract, today)
            billing_service.prepare
            billing_service.call
          end
        end
      rescue Exception => e
        Airbrake.notify('Failed billing task', {
          error: e.class,
          message: e.message
        })
        puts "#{contract.id}: #{e}"
      end
    end
  end
end