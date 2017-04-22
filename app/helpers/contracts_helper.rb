module ContractsHelper
  def format_contract_status_collection
    Contract::CONTRACT_STATUSES_ENUM.map do |key, _|
      ["#{I18n.t("types.contract_statuses.#{key}")}", key]
    end
  end

  def format_contract_duration_types_for_select
    Contract::CONTRACT_DURATION_TYPES_ENUM.map do |key, _|
      ["#{I18n.t("types.contract_duration_types.#{key}.title")}", key]
    end
  end
end