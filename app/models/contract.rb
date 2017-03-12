class Contract < ApplicationRecord

  CONTRACT_STATUS = {creation: 1, commercial_validation_sp: 4, commercial_validation_client: 7,  price_validation_sp: 10, price_validation_client: 13, Validation: 16}
  enum status: CONTRACT_STATUS

  integer offset: 3

  belongs_to :user
  belongs_to :company
  belongs_to :client, class_name: "Service"
  belongs_to :startup, class_name: "Service"
  belongs_to :price

  validates :name, presence: true
  validates :startup_id, presence:true
  validates :client_id, presence:true
  validates :startup_id, uniqueness: {scope: [:client_id]}

  scope :associated_companies, ->(company) { where(company: company) }
  scope :associated_clients, ->(client) { where(client: client) }
  scope :associated_startups, ->(startup) { where(startup: startup) }
  scope :associated_startups_clients, ->(cur_service) { where('startup_id=? OR client_id=?',cur_service.id, cur_service.id) }

  scope :owned, ->(user) { where(user: user) }

  def authorized_to_act?(user)
    return (user.has_role?(:superadmin) || user.has_role?(:commercial, self.client) || user.has_role?(:commercial, self.startup) || user.has_role?(:commercial, self.company))
  end

  def authorized_to_create?(user)
    user.has_role?(:superadmin) || user.has_role?(:commercial)
  end

  def is_accounting?(user, scope = :client)
    user.has_role?(:superadmin) || user.has_role?(:accounting, self.send(scope))
  end

  def is_commercial?(user, scope = :client)
    user.has_role?(:superadmin) || user.has_role?(:commercial, self.send(scope))
  end
end
