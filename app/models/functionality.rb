class Functionality < ApplicationRecord
  FUNCTIONALITY_TYPES = {database: 1, proxy: 2}
  enum type: FUNCTIONALITY_TYPES

  belongs_to :service
  belongs_to :user

  belongs_to :proxy_parameter, optional: true, autosave: true

  validates :type, presence: true

  validates :name, presence: true, length: {minimum: 2, maximum: 255}
  validates :description, presence: true

  scope :authorized, ->(user) { user.has_role?(:superadmin) ? all : with_role(:developer, user) }

  def authorized?(user)
    user.has_role?(:superadmin) || user.has_role?(:developer, self)
  end

  def assign_default_user_role
    self.user.add_role(:developer, self)
  end

  def type_humanize
    I18n.t("types.functionality_types.#{self.type}")
  end

  def self.inheritance_column
    nil
  end
end
