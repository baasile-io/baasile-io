
module ContractsHelper

  def format_contract_status_collection
    Contract::CONTRACT_STATUS.map do |key, _|
      ["#{I18n.t("types.contract_status.#{key}")}", key]
    end
  end
end