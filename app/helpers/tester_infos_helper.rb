module TesterInfosHelper
  def format_req_types_for_select
    TesterInfo::REQ_REST_TYPES.map do |key, _|
      ["#{I18n.t("types.req_types.#{key}")}", key]
    end
  end
end
