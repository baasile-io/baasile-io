
module ContractsHelper

  def format_contract_status_collection
    Contract::CONTRACT_STATUSES_ENUM.map do |key, _|
      ["#{I18n.t("types.contract_statuses.#{key}")}", key]
    end
  end
end