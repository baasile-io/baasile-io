class Price < ApplicationRecord

  belongs_to :proxy
  belongs_to :service
  belongs_to :user
  has_many :PriceParameters
  has_many :contracts

  validates :name, presence: true
  validates :user, presence: true
  validates :service, presence: true

  scope :owned, ->(user) { where(user: user) }

  def dup_attached(current_price)
    unless current_price.nil?
      current_price.price_parameters.destroy_all
      current_price.destroy
    end
    new_price = self.dup
    new_price.attached = true
    new_price.save
    return new_price
  end

  def full_name
    self.service.name + ' - ' + self.name
  end

end
