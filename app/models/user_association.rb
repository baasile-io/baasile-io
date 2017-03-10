class UserAssociation < ApplicationRecord
  # Versioning
  has_paper_trail

  belongs_to :associable, polymorphic: true
  belongs_to :user

  validates :associable, presence: true
  validates :user_id, presence: true
end
