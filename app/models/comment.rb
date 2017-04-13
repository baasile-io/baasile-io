class Comment < ApplicationRecord
  # Versioning
  has_paper_trail

  include Trixable
  has_trix_attributes :body

  belongs_to :commentable, polymorphic: true
  belongs_to :user

  validates :user, presence: true
  validates :commentable, presence: true
  validates :body, presence: true

  scope :active, -> { where(deleted: false) }
end