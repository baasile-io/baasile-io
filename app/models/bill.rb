class Bill < ApplicationRecord
  belongs_to :contract
  has_many :bill_lines
end
