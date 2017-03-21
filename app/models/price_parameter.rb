class PriceParameter < ApplicationRecord

  PRICE_PARAMETERS_TYPES = {per_call: 1, per_params: 2}
  enum price_parameters_type: PRICE_PARAMETERS_TYPES

  belongs_to :price
  belongs_to :user
  belongs_to :route

  validates :route_id, presence: true
  validates :price, presence: true

  def dup_attached(current_price)
    new_price_param = self.dup
    new_price_param.attached = true
    new_price_param.price = current_price
    new_price_param.save
    return new_price_param
  end

end
