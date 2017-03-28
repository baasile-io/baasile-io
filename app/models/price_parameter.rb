class PriceParameter < ApplicationRecord

  PRICE_PARAMETERS_TYPES = {per_call: 1, per_params: 2}
  enum price_parameters_type: PRICE_PARAMETERS_TYPES

  belongs_to :price
  belongs_to :user
  belongs_to :route
  belongs_to :query_parameter

  validates :price, presence: true
  validates :price_parameters_type, presence: true
  validates :cost, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :free_count, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :deny_after_free_count, presence: true
  validates :query_parameter, presence: true, if: Proc.new {self.price_parameters_type.to_sym == :per_params}
  validate :undefined_cost_and_free_count
  validate :deny_after_free_count_validity

  def dup_attached(current_price)
    new_price_param = self.dup
    new_price_param.attached = true
    new_price_param.price = current_price
    new_price_param.save
    return new_price_param
  end

  def undefined_cost_and_free_count
    self.errors.add(:base, I18n.t('errors.models.price_parameter.undefined_cost_and_free_count')) if self.free_count == 0 && self.cost == 0.0
  end

  def deny_after_free_count_validity
    self.errors.add(:base, I18n.t('errors.models.price_parameter.deny_after_free_count_validity')) if self.deny_after_free_count && (self.free_count == 0 || self.cost > 0.0)
  end

end
