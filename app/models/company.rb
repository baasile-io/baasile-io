class Company < ApplicationRecord

  belongs_to :service
  belongs_to :user
  validates :name, uniqueness: true, presence: true, length: {minimum: 2, maximum: 255}

end
