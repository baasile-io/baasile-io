class Price < ApplicationRecord

  # Versioning
  has_paper_trail

  belongs_to :proxy
  belongs_to :service
  belongs_to :user
  belongs_to :contract

  has_many :price_parameters, dependent: :destroy

  before_validation :set_default_params_for_contract

  validates :name, presence: true, unless: :contract_id?
  validates :user, presence: true
  validates :service, presence: true
  validates :proxy, presence: true
  validates :base_cost, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :cost_by_time, presence: true, numericality: {greater_than_or_equal_to: 0}

  scope :owned, ->(user) { where(user: user) }
  scope :templates, ->(proxy) { where(contract_id: nil, proxy: proxy) }

  def dup_attached(current_price)
    current_price.try(:destroy)
    new_price = self.dup
    new_price.save
    return new_price
  end

  def is_correct?
    tab_check_param = []
    self.price_parameters.each do |p_p|
      if p_p.price_parameters_type == "per_params"
        if p_p.query_parameter_id.nil?
          tselected_only_param = tab_check_param.select { |qp| qp > 0 }
          if !tab_check_param.include?(-1) && tselected_only_param.count == 0
            tab_check_param << -1
          else
            return [false, I18n.t("misc.all") + " " + I18n.t("errors.messages.used_multiple_time")]
          end
        elsif !tab_check_param.include?(p_p.query_parameter_id) && !tab_check_param.include?(-1)
          tab_check_param << p_p.query_parameter_id
        else
          return [false, p_p.query_parameter.name + " " + I18n.t("misc.all") + I18n.t("errors.messages.invalid")] if tab_check_param.include?(-1)
          return [false, p_p.query_parameter.name + " " + I18n.t("errors.messages.used_multiple_time")]
        end
      elsif p_p.price_parameters_type == "per_call"
        if !tab_check_param.include?(-2)
          tab_check_param << -2
        else
          return [false, I18n.t("types.price_parameters_types.per_call.title") + ' ' + I18n.t("errors.messages.used_multiple_time")]
        end
      else
        return false
      end
    end
    return true
  end

  def full_name
    self.service.name + ' - ' + self.name
  end

  def set_default_params_for_contract
    if self.contract
      self.service = self.contract.startup
      self.proxy = self.contract.proxy
    end
  end

end
