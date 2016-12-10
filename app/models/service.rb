class Service < ApplicationRecord
  belongs_to :creator, class_name: 'User', foreign_key: 'user_id'

  validates :name, presence: true, length: {maximum: 255}
  validates :description, presence: true

  def validated?
    !self.confirmed_at.nil?
  end
end
