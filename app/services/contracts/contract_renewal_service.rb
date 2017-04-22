module Contracts
  class ContractRenewalService
    def initialize(contract)
      @contract = contract
    end

    def renew
      @contract.end_date = case @contract.contract_duration_type.to_sym
                             when :monthly
                               renew_monthly_duration
                             when :yearly
                               renew_yearly_duration
                             else
                               renew_custom_duration
                           end
      update_contract_duration
      @contract.save
    end

    def update_contract_duration
      @contract.contract_duration = (@contract.end_date - @contract.start_date).to_i + 1
    end

    def renew_monthly_duration
      @contract.end_date + 1.month
    end

    def renew_yearly_duration
      @contract.end_date + 1.year
    end

    def renew_custom_duration
      @contract.end_date + @contract.expected_contract_duration
    end
  end
end