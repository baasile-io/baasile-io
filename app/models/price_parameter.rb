class PriceParameter < ApplicationRecord

  belongs_to :price
  belongs_to :user

  validates :name, presence: true
  validates :price, presence: true

end
