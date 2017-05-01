class Bill < ApplicationRecord
  belongs_to :contract

  has_many :bill_lines
  has_one :client, through: :contract
  has_one :startup, through: :contract
  has_many :comments, as: :commentable

  validates :bill_month, uniqueness: {scope: :contract}

  scope :by_service, ->(service) { joins(:contract).where("contracts.startup_id IN (:service_ids) OR contracts.client_id IN (:service_ids)", service_ids: service.subtree_ids) }
  scope :by_user, ->(user) { joins(:contract).where("contracts.startup_id IN (:service_ids) OR contracts.client_id IN (:service_ids)", service_ids: user.services.map {|s| s.subtree_ids}.flatten.uniq) }
end
