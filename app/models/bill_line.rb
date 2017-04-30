class BillLine < ApplicationRecord

  LINE_TYPES = {
    amount: {
      index: 0,
      computed_amounts: true
    },
    separator: {
      index: 1,
      computed_amounts: false
    },
    supplier: {
      index: 2,
      computed_amounts: false
    },
    subtotal: {
      index: 3,
      computed_amounts: false
    }
  }
  LINE_TYPES_ENUM = LINE_TYPES.each_with_object({}) { |line_type, h| h[line_type[0]] = line_type[1][:index] }
  enum line_type: LINE_TYPES_ENUM

  belongs_to :bill
  has_one :contract, through: :bill

  before_validation :calculate_computed_amounts

  def calculate_computed_amounts
    if LINE_TYPES[self.line_type.to_sym][:computed_amounts]
      self.total_cost = self.unit_num * self.unit_cost.round(2)
      self.total_cost_including_vat = (self.total_cost + (self.total_cost * self.vat_rate / 100.0)).round(2)
    end
  end
end
