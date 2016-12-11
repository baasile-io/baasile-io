class Service < ApplicationRecord
  # User rights
  resourcify
  after_create :assign_default_user_role
  after_destroy :

  belongs_to :user

  validates :name, presence: true, length: {minimum: 2, maximum: 255}
  validates :description, presence: true

  scope :authorized, ->(user) { user.has_role?(:superadmin) ? all : with_role(:developer, user) }

  def authorized?(user)
    user.has_role?(:superadmin) || user.has_role?(:developer, self)
  end

  def is_locked?
    self.confirmed_at.nil?
  end

  def assign_default_user_role
    self.user.add_role(:developer, self)
  end

  def do_unlock!
    if Apartment::Tenant.create(self.id)
      self.confirmed_at = Date.new
      self.save
    end
  end
end
