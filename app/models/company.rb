class Company < ApplicationRecord
  # User rights
  resourcify
  after_create :assign_default_user_role

  # Versioning
  has_paper_trail

  belongs_to :user
  has_many :services
  has_one :contact_detail, as: :contactable, dependent: :destroy

  has_many :user_associations, as: :associable
  has_many :users, through: :user_associations

  after_destroy :remove_services_associations

  accepts_nested_attributes_for :contact_detail, allow_destroy: true

  validates :name, uniqueness: true, presence: true, length: {minimum: 2, maximum: 255}
  validates :contact_detail, presence: true

  scope :authorized, ->(user) { user.has_role?(:superadmin) ? all : find_as(:admin, user) }
  scope :owned, ->(user) { where(user: user) }

  def authorized?(user)
    user.has_role?(:superadmin) || user.has_role?(:admin, self)
  end

  def assign_default_user_role
    self.user.add_role(:admin, self)
  end

  def remove_services_associations
    services = Service.associated(self)
    services.each do |service|
      service.company_id = nil
      service.save(validate: false)
    end
  end
end
