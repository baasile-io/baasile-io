class Bill < ApplicationRecord
  belongs_to :contract

  has_many :bill_lines

  validates :bill_month, uniqueness: {scope: :contract}
end
