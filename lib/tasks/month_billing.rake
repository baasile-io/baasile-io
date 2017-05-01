namespace 'month_billing' do
  desc "Create bills of the month"
  task :create => :environment do |t, args|
    current_month = Date.today.beginning_of_month
    previous_month = current_month - 1.month
    Contract.active_between(previous_month, previous_month.end_of_month).each do |contract|
      puts "Processing contract #{contract.id}"
      billing_service = Bills::BillingService.new(contract, previous_month)
      billing_service.calculate
      billing_service.create_bill(current_month + 10.days)
    end
  end
end