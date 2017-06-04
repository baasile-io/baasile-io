module Contracts
  class ContractCheckFreeCountLimit
    def initialize(contract, route = nil)
      @contract = contract
      @route = route
    end

    def call
      check
    end

    private

      attr_reader :contract, :route

      def check

        if contract.price.pricing_duration_type.to_sym == :prepaid
          if requests_limit != false

            measurements = Measurement.by_contract_status(contract)
            requests_count = case contract.price.pricing_type.to_sym
                               when :per_call
                                 measurements.sum(:requests_count)
                               when :per_parameter
                                 measurements.select(:measure_token_id).distinct.count
                             end

            if requests_count >= requests_limit
              return false
            end

          end
        end

        true
      end

      def requests_limit
        case contract.price.pricing_type.to_sym
          when :per_parameter
            if route.nil? || route.measure_token_activated
              if contract.price.deny_after_free_count
                contract.price.free_count
              end
            end
          when :per_call
            if contract.price.deny_after_free_count
              contract.price.free_count
            end
        end
        false
      end

  end
end