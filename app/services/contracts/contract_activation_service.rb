module Contracts
  class ContractActivationService
    def initialize(contract, start_date = Date.today)
      @contract = contract
      @start_date = start_date
    end

    def activate
      case @contract.contract_duration_type.to_sym
        when :monthly
          activate_monthly_duration
        when :yearly
          activate_yearly_duration
        else
          activate_custom_duration
      end
      update_contract_duration
      @contract.save
    end

    def update_contract_duration
      @contract.contract_duration = (@contract.end_date - @start_date).to_i
    end

    def activate_monthly_duration
      @contract.start_date = @start_date
      @contract.end_date = @start_date + 1.month
    end

    def activate_yearly_duration
      @contract.start_date = @start_date
      @contract.end_date = @start_date + 1.year
    end

    def activate_custom_duration
      @contract.start_date = @contract.expected_start_date
      @contract.end_date = @contract.expected_end_date
    end
  end
end