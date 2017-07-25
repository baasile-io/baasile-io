class Bill < ApplicationRecord
  # Versioning
  has_paper_trail

  belongs_to :contract

  has_many  :bill_lines, dependent: :restrict_with_error
  has_one   :client, through: :contract
  has_one   :startup, through: :contract
  has_many  :comments, as: :commentable, dependent: :destroy

  scope :by_month,    ->(date) { where("to_char(bills.start_date, 'YYYY-MM') = ?", date.strftime('%Y-%m')) }
  scope :by_contract, ->(contract) { where(contract: contract) }
  scope :by_service,  ->(service) { joins(:contract).where("contracts.startup_id IN (:service_ids) OR contracts.client_id IN (:service_ids)", service_ids: service.subtree_ids) }
  scope :by_user,     ->(user) { joins(:contract).where("contracts.startup_id IN (:service_ids) OR contracts.client_id IN (:service_ids)", service_ids: user.services.map {|s| s.subtree_ids}.flatten.uniq) }

  before_save :set_paid_state

  def set_paid_state
    self.paid = if (self.startup_paid? && self.platform_contribution_paid?)
                  self.startup_paid > self.platform_contribution_paid ? self.startup_paid : self.platform_contribution_paid
                else
                  nil
                end
  end

  def paid?
    !self.paid.nil?
  end

  def startup_paid?
    !self.startup_paid.nil?
  end

  def platform_contribution_paid?
    !self.platform_contribution_paid.nil?
  end

  def mark_startup_as_paid
    self.startup_paid = DateTime.now unless startup_paid?
  end

  def mark_platform_contribution_as_paid
    self.platform_contribution_paid = DateTime.now unless platform_contribution_paid?
  end

end
