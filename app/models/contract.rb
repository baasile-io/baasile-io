class Contract < ApplicationRecord
  belongs_to :user
  belongs_to :company
  belongs_to :client, class_name: "Service"
  belongs_to :startup, class_name: "Service"

  scope :client_associated, ->(client) { where(client: client) }
  scope :company_associated, ->(company) { where(company: company) }
  scope :service_associated, ->(startup) { where(startup: startup) }
  scope :owned, ->(user) { where(user: user) }

  def authorized?(user)
    user.is_commercial?
  end

end
