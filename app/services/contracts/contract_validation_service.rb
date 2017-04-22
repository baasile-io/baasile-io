module Contracts
  class ContractValidationService
    class MissingContract < StandardError; end
    class NotValidatedContract < StandardError; end
    class MissingStartDateProductionPhase < StandardError; end
    class NotStartedProductionPhase < StandardError; end
    class EndedProductionPhase < StandardError; end

    def initialize(contract, route)
      @contract = contract
      @route = route
    end

    def authorize_request
      raise MissingContract if @contract.nil?

      case contract_status
        when :validation
          authorize_test_request
        when :validation_production
          authorize_production_request
        else
          raise NotValidatedContract
      end

      true
    rescue MissingContract
      [false, 'No subscription to this product']
    rescue NotValidatedContract
      [false, 'No active subscription to this product']
    rescue MissingStartDateProductionPhase
      [false, "Production phase has no start date"]
    rescue NotStartedProductionPhase
      [false, "Production phase will start on #{I18n.l(@contract.start_date)}"]
    rescue EndedProductionPhase
      [false, "Production phase ended on #{I18n.l(@contract.end_date)}"]
    end

    def authorize_test_request
      true
    end

    def authorize_production_request
      return ContractActivationService.new(@contract).activate if start_date.nil?
      raise NotStartedProductionPhase if today < start_date
      if today >= end_date
        raise EndedProductionPhase unless is_evergreen
        return ContractRenewalService.new(@contract).renew
      end
      true
    end

    def contract_status
      @contract.status.to_sym
    end

    def today
      @today ||= Date.today
    end

    def is_evergreen
      @contract.is_evergreen
    end

    def start_date
      @contract.start_date
    end

    def end_date
      @contract.end_date
    end
  end
end