class Price < ApplicationRecord

  # Versioning
  has_paper_trail

  belongs_to :proxy
  belongs_to :service
  belongs_to :user
  belongs_to :contract

  has_many :price_parameters, dependent: :destroy

  before_validation :set_default_params_for_contract

  validates :name, presence: true, unless: :contract_id?
  validates :user, presence: true
  validates :service, presence: true
  validates :proxy, presence: true
  validates :base_cost, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :cost_by_time, presence: true, numericality: {greater_than_or_equal_to: 0}

  scope :owned, ->(user) { where(user: user) }
  scope :templates, ->(proxy) { where(contract_id: nil, proxy: proxy) }

  def dup_attached(current_price)
    current_price.try(:destroy)
    new_price = self.dup
    new_price.save
    return new_price
  end

  def full_name
    self.service.name + ' - ' + self.name
  end

  def set_default_params_for_contract
    if self.contract
      self.service = self.contract.startup
      self.proxy = self.contract.proxy
    end
  end

end
