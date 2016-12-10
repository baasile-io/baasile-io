class Service < ApplicationRecord
  belongs_to :user

  validates :name, presence: true, length: {minimum: 2, maximum: 255}
  validates :description, presence: true

  def validated?
    !self.confirmed_at.nil?
  end
end
