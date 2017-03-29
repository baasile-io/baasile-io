class Category < ApplicationRecord

  belongs_to :user

  validates :name, uniqueness: true, presence: true, length: {minimum: 2, maximum: 255}
  validates :description, presence: true, length: {minimum: 2, maximum: 255}

end
