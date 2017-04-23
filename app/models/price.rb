class Price < ApplicationRecord

  PRICING_DURATION_TYPES = {
    prepaid: { index: 0 },
    monthly: { index: 1 },
    yearly:  { index: 2 }
  }
  PRICING_DURATION_TYPES_ENUM = PRICING_DURATION_TYPES.each_with_object({}) do |k, h| h[k[0]] = k[1][:index] end
  enum pricing_duration_type: PRICING_DURATION_TYPES_ENUM

  PRICING_TYPES = {
    subscription: { index: 0 },
    per_call: { index: 1 },
    per_parameter:  { index: 2 }
  }
  PRICING_TYPES_ENUM = PRICING_TYPES.each_with_object({}) do |k, h| h[k[0]] = k[1][:index] end
  enum pricing_type: PRICING_TYPES_ENUM

  # Versioning
  has_paper_trail

  belongs_to :proxy
  belongs_to :service
  belongs_to :user
  belongs_to :contract
  belongs_to :route
  belongs_to :query_parameter

  has_many :price_parameters, dependent: :destroy

  before_validation :set_default_params_for_contract

  validates :name, presence: true, unless: :contract_id?
  validates :user, presence: true
  validates :service, presence: true
  validates :proxy, presence: true

  validates :base_cost, presence: true, numericality: {greater_than: 0}
  validates :cost, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :unit_cost, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :free_count, presence: true, numericality: {greater_than: 0}, if: Proc.new {self.pricing_type.to_sym != :subscription}
  validates :deny_after_free_count, inclusion: {in: [true, false]}, if: Proc.new {self.pricing_type.to_sym != :subscription}
  validate :price_options_consistency

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

  def price_options_consistency
    case self.pricing_type.to_sym
      when :subscription
      else
        if !self.deny_after_free_count && self.unit_cost == 0
          self.errors.add(:unit_cost, I18n.t('errors.messages.blank'))
        end
    end
    if self.pricing_type.to_sym == :per_parameter
      unless self.proxy.routes.exists?(measure_token_activated: true)
        self.errors.add(:base, I18n.t('errors.messages.missing_measure_token_activated_route'))
      end
    end
  end

end
