module Contracts
  class ContractValidationService
    class MissingContract < StandardError; end
    class NotValidatedContract < StandardError; end
    class MissingStartDateProductionPhase < StandardError; end
    class NotStartedProductionPhase < StandardError; end
    class EndedProductionPhase < StandardError; end
    class WaitingForProduction < StandardError; end
    class NotActive < StandardError; end

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
        when :waiting_for_production
          raise WaitingForProduction
        else
          raise NotValidatedContract
      end

      case contract_pricing_type
        when :per_call
          authorize_request_per_call
      end

      raise NotActive unless @contract.is_active

      true
    rescue MissingContract
      [false, 'No contract found with this product']
    rescue NotValidatedContract
      [false, "No active contract found with this product (status: #{@contract.status})"]
    rescue MissingStartDateProductionPhase
      [false, "Production phase has no start date"]
    rescue NotStartedProductionPhase
      [false, "Production phase will start on #{I18n.l(@contract.start_date, locale: :en)}"]
    rescue EndedProductionPhase
      [false, "Production phase ended on #{I18n.l(@contract.end_date, locale: :en)}"]
    rescue WaitingForProduction
      [false, "Waiting for production phase"]
    rescue NotActive
      [false, "Contract is temporarily deactivated"]
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

    def authorize_request_per_call
      return unless contract_price_deny_after_free_count

      case contract_pricing_duration_type
        when :prepaid
          MeasureToken.by_contract_status(@contract).first_or_create!
      end
    end

    def contract_status
      @contract.status.to_sym
    end

    def contract_pricing_type
      @contract.price.pricing_type
    end

    def contract_pricing_duration_type
      @contract.price.pricing_duration_type
    end

    def contract_price_deny_after_free_count
      @contract.price.deny_after_free_count
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