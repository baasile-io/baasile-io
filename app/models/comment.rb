class Comment < ApplicationRecord
  # Versioning
  has_paper_trail

  belongs_to :commentable, polymorphic: true
  belongs_to :user

  validates :user, presence: true
  validates :commentable, presence: true
  validates :body, presence: true

  scope :active, -> { where(deleted: false) }
end