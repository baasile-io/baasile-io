module Contracts
  class ContractResetFreeCountLimit
    def initialize(contract)
      @contract = contract
    end

    def call
      reset
    end

    private

      attr_reader :contract

      def reset
        Measurement.by_contract_status(contract).destroy_all
      end

  end
end