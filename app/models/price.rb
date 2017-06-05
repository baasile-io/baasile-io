class Price < ApplicationRecord

  PRICING_DURATION_TYPES = {
    monthly: { index: 0 },
    yearly:  { index: 1 },
    prepaid: { index: 2 }
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

  belongs_to :proxy, touch: true
  belongs_to :service
  belongs_to :user
  belongs_to :contract
  belongs_to :route
  belongs_to :query_parameter

  has_many :price_parameters, dependent: :destroy

  # TODO remove association, and make it via ":through"
  before_validation :set_default_params

  validates :name, presence: true, unless: :contract_id?
  validates :user, presence: true
  validates :service, presence: true
  validates :proxy, presence: true

  validates :base_cost,
            presence: true,
            numericality: {greater_than: 0}

  validates :cost,
            presence: true,
            numericality: {greater_than_or_equal_to: 0}

  validates :unit_cost,
            presence: true,
            numericality: {greater_than_or_equal_to: 0}

  validates :free_count,
            presence: true,
            numericality: {greater_than: 0},
            if: Proc.new {self.pricing_type.to_sym != :subscription}

  validates :deny_after_free_count,
            inclusion: {in: [true, false]},
            if: Proc.new {self.pricing_type.to_sym != :subscription}

  validates :pricing_duration_type,
            inclusion: {in: ['monthly', 'yearly', :monthly, :yearly]},
            if: Proc.new {self.pricing_type.to_sym == :subscription}

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

  def set_default_params
    if self.contract
      self.proxy = self.contract.proxy
      self.service = self.contract.proxy.service
    else
      self.service = self.proxy.service
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
      if self.pricing_duration_type.to_sym != :prepaid
        self.errors.add(:pricing_duration_type, I18n.t('errors.messages.pricing_per_parameter_must_be_prepaid'))
      end
      unless self.proxy.routes.exists?(measure_token_activated: true)
        self.errors.add(:base, I18n.t('errors.messages.missing_measure_token_activated_route'))
      end
    end
  end

end
