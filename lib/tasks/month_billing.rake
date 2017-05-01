namespace 'month_billing' do
  desc "Create bills of the month"
  task :create => :environment do |t, args|
    current_month = Date.today.beginning_of_month
    previous_month = current_month - 1.month
    Contract.active_between(previous_month, previous_month.end_of_month).each do |contract|
      begin
        puts "Processing contract #{contract.id}"
        if contract.bills.where(bill_month: previous_month).exists?
          puts "#{contract.id}: Already billed"
        else

          billing_service = Bills::BillingService.new(contract, previous_month)
          billing_service.calculate
          billing_service.create_bill(current_month + Appconfig.get(:bill_payment_deadline).days)
        end
      rescue Bills::BillingService::ContractNotStartedError
        puts "#{contract.id}: ContractNotStartedError"
      rescue Bills::BillingService::ContractEndedError
        puts "#{contract.id}: ContractEndedError"
      rescue Bills::BillingService::MissingPriceProxyClientError
        puts "#{contract.id}: MissingPriceProxyClientError"
      rescue Bills::BillingService::InvalidBillRecordError
        puts "#{contract.id}: InvalidBillRecordError"
      end
    end
  end
end