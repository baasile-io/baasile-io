class Company < ApplicationRecord
  resourcify
  has_many :services
  belongs_to :user
  has_one :contact_detail, as: :contactable, dependent: :destroy
  before_destroy :remove_services_associations

  accepts_nested_attributes_for :contact_detail, allow_destroy: true

  validates :name, uniqueness: true, presence: true, length: {minimum: 2, maximum: 255}
  validates :contact_detail, presence: true

  scope :authorized, ->(user) { user.has_role?(:superadmin) ? all : find_as(:admin, user) }
  scope :owned, ->(user) { where(user_id: user.id) }

  def authorized?(user)
    user.has_role?(:superadmin) || user.has_role?(:admin, self)
  end

  def remove_services_associations
    services = Service.associated(self)
    services.each do |service|
      service.company_id = nil
    end
  end
end
